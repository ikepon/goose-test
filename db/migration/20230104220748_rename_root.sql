-- +goose Up

UPDATE users SET username='admin' WHERE username='root';

-- +goose Down

UPDATE users SET username='root' WHERE username='admin';
