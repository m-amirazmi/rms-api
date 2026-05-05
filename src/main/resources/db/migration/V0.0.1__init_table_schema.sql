-- =========================
-- TENANTS
-- =========================
CREATE TYPE tenant_status AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETED');
CREATE TABLE tenants
(
    id         UUID PRIMARY KEY       DEFAULT gen_random_uuid(),
    name       VARCHAR(150)  NOT NULL,
    slug       VARCHAR(150)  NOT NULL UNIQUE, -- used for subdomain later (e.g. kl.store.com)
    status     tenant_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tenants_slug ON tenants (slug);


-- =========================
-- USERS (GLOBAL IDENTITY)
-- =========================
CREATE TABLE users
(
    id            UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(150),
    phone_number  VARCHAR(30),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP,

    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users (email);


-- =========================
-- TENANT USERS (MEMBERSHIP)
-- =========================
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INVITED', 'SUSPENDED', 'REMOVED');
CREATE TABLE tenant_users
(
    id         UUID PRIMARY KEY     DEFAULT gen_random_uuid(),
    tenant_id  UUID        NOT NULL,
    user_id    UUID        NOT NULL,
    status     user_status NOT NULL DEFAULT 'ACTIVE',
    job_title  VARCHAR(100),
    created_at TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP   NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tenant_users_tenant
        FOREIGN KEY (tenant_id) REFERENCES tenants (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_tenant_users_user
        FOREIGN KEY (user_id) REFERENCES users (id)
            ON DELETE CASCADE,

    CONSTRAINT uq_tenant_user UNIQUE (tenant_id, user_id)
);

CREATE INDEX idx_tenant_users_tenant_id ON tenant_users (tenant_id);
CREATE INDEX idx_tenant_users_user_id ON tenant_users (user_id);
