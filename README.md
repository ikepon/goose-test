# Goose の動作テストリポジトリ

https://github.com/pressly/goose

## Goose テスト

- install

```
go install github.com/pressly/goose/v3/cmd/goose@latest
```

- db 起動

```
docker compose up
```

- goose 動かす

```
# migration ファイルを置くディレクトリ作成
➜  goose-test git:(main) ✗ mkdir -p db/migration

# migrationファイル作成
➜  goose-test git:(main) ✗ goose -dir db/migration create craete_users_table sql
2023/01/04 22:05:53 Created new file: 20230104220553_craete_users_table.sql
➜  goose-test git:(main) ✗ goose -dir db/migration create rename_root sql
2023/01/04 22:07:48 Created new file: 20230104220748_rename_root.sql
➜  goose-test git:(main) ✗ goose -dir db/migration create no_transaction sql
2023/01/04 22:08:51 Created new file: 20230104220851_no_transaction.sql

# 作成した migration ファイルの確認
➜  goose-test git:(main) ✗ goose -dir db/migration status
2023/01/04 22:38:40     Applied At                  Migration
2023/01/04 22:38:40     =======================================
2023/01/04 22:38:40     Pending                  -- 20230104220553_craete_users_table.sql
2023/01/04 22:38:40     Pending                  -- 20230104220748_rename_root.sql
2023/01/04 22:38:40     Pending                  -- 20230104220851_no_transaction.sql

# 実行
# pending になっているものがすべて実行される
➜  goose-test git:(main) ✗ goose -dir db/migration up
2023/01/07 10:34:38 OK    20230104220553_craete_users_table.sql
2023/01/07 10:34:38 OK    20230104220748_rename_root.sql
2023/01/07 10:34:38 OK    20230104220851_no_transaction.sql
2023/01/07 10:34:38 goose: no migrations to run. current version: 20230104220851

# 戻す
# 戻すと一番最後に実行されたものから一つずつもどる
➜  goose-test git:(main) ✗ goose -dir db/migration down
2023/01/07 10:37:56 OK    20230104220851_no_transaction.sql
➜  goose-test git:(main) ✗ goose -dir db/migration status
2023/01/07 10:38:02     Applied At                  Migration
2023/01/07 10:38:02     =======================================
2023/01/07 10:38:02     Sat Jan  7 01:34:38 2023 -- 20230104220553_craete_users_table.sql
2023/01/07 10:38:02     Sat Jan  7 01:34:38 2023 -- 20230104220748_rename_root.sql
2023/01/07 10:38:02     Pending                  -- 20230104220851_no_transaction.sql

# 再実行
# 未実行のもののみ実行される
➜  goose-test git:(main) ✗ goose -dir db/migration up
2023/01/07 10:38:35 OK    20230104220851_no_transaction.sql
2023/01/07 10:38:35 goose: no migrations to run. current version: 20230104220851
```

## migration の管理

実行したものの管理は `goose_db_version` ってテーブルが自動で作られて、そこで管理してるっぽい

```
# db に入る
➜  goose-test git:(main) ✗ docker-compose exec postgresdb bash
root@bd8d6b090398:/# psql -U postgres
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.

# 初期状態
goose-test=# \dt;
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+----------
 public | goose_db_version | table | postgres
(1 row)

goose-test=# select * from goose_db_version;
 id | version_id | is_applied |           tstamp
----+------------+------------+----------------------------
  1 |          0 | t          | 2023-01-04 12:59:19.074566

# goose up 実行
goose-test=# select * from goose_db_version;
 id |   version_id   | is_applied |           tstamp
----+----------------+------------+----------------------------
  1 |              0 | t          | 2023-01-04 12:59:19.074566
 10 | 20230104220553 | t          | 2023-01-07 01:53:28.445772
 11 | 20230104220748 | t          | 2023-01-07 01:53:28.515849
 12 | 20230104220851 | t          | 2023-01-07 01:53:28.544031
(4 rows)

# goose down 2 回実行
goose-test=# select * from goose_db_version;
 id |   version_id   | is_applied |           tstamp
----+----------------+------------+----------------------------
  1 |              0 | t          | 2023-01-04 12:59:19.074566
 10 | 20230104220553 | t          | 2023-01-07 01:53:28.445772

# もう一回 goose up
goose-test=# select * from goose_db_version;
 id |   version_id   | is_applied |           tstamp
----+----------------+------------+----------------------------
  1 |              0 | t          | 2023-01-04 12:59:19.074566
 10 | 20230104220553 | t          | 2023-01-07 01:53:28.445772
 13 | 20230104220748 | t          | 2023-01-07 01:55:20.431672
 14 | 20230104220851 | t          | 2023-01-07 01:55:20.505855
```
