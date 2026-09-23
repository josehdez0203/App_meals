-- Esquema de la API de delivery.
-- Equivalente a server/db/init.sql (version NestJS + TypeORM), validado contra
-- las entidades de TypeORM. Se omite `typeorm_metadata` por ser un artefacto
-- interno de TypeORM sin uso en Go.

CREATE EXTENSION IF NOT EXISTS postgis;

-- -----------------------------------------------------------------------------
-- Tablas (ordenadas por dependencias de claves foraneas)
-- -----------------------------------------------------------------------------

CREATE TABLE "user" (
    id                   serial       NOT NULL,
    "idGoogle"           text,
    "fullName"           text         NOT NULL,
    email                text         NOT NULL,
    phone                text,
    password             text         NOT NULL,
    "passwordTemporary"  text,
    image                text         NOT NULL DEFAULT '',
    "isActive"           boolean      NOT NULL DEFAULT true,
    roles                text[]       NOT NULL DEFAULT '{client}',
    "createdAt"          timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT "PK_user" PRIMARY KEY (id),
    CONSTRAINT "UQ_user_idGoogle" UNIQUE ("idGoogle"),
    CONSTRAINT "UQ_user_email" UNIQUE (email),
    CONSTRAINT "UQ_user_phone" UNIQUE (phone)
);

CREATE TABLE category (
    id           serial       NOT NULL,
    name         text         NOT NULL,
    image        text         NOT NULL DEFAULT 'https://cdn-icons-png.flaticon.com/512/685/685352.png',
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT "PK_category" PRIMARY KEY (id),
    CONSTRAINT "UQ_category_name" UNIQUE (name)
);

CREATE TABLE company (
    id           serial       NOT NULL,
    name         text         NOT NULL,
    address      text         NOT NULL,
    contact      text         NOT NULL,
    image        text         NOT NULL DEFAULT '',
    marker       text         NOT NULL DEFAULT '',
    email        text         NOT NULL,
    location     point        NOT NULL,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz  NOT NULL DEFAULT now(),
    "userId"     integer,
    CONSTRAINT "PK_company" PRIMARY KEY (id),
    CONSTRAINT "UQ_company_name" UNIQUE (name),
    CONSTRAINT "FK_company_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE company_category (
    id            serial       NOT NULL,
    "updatedAt"   timestamptz  NOT NULL DEFAULT now(),
    "companyId"   integer      NOT NULL,
    "categoryId"  integer      NOT NULL,
    CONSTRAINT "PK_company_category" PRIMARY KEY (id),
    CONSTRAINT "UQ_company_category" UNIQUE ("companyId", "categoryId"),
    CONSTRAINT "FK_company_category_company" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE,
    CONSTRAINT "FK_company_category_category" FOREIGN KEY ("categoryId") REFERENCES category (id) ON DELETE CASCADE
);

CREATE TABLE store (
    id             serial              NOT NULL,
    name           text                NOT NULL,
    address        text                NOT NULL,
    contact        text                NOT NULL,
    email          text                NOT NULL,
    "startupCost"  double precision    NOT NULL DEFAULT '1.25'::double precision,
    "costKm"       double precision    NOT NULL DEFAULT '0.55'::double precision,
    location       point               NOT NULL,
    sales          integer             NOT NULL DEFAULT 0,
    "createdAt"    timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"    timestamptz         NOT NULL DEFAULT now(),
    "deletedAt"    timestamp,
    "companyId"    integer,
    "userId"       integer,
    CONSTRAINT "PK_store" PRIMARY KEY (id),
    CONSTRAINT "FK_store_company" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE,
    CONSTRAINT "FK_store_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE hours_operation (
    id          serial      NOT NULL,
    day         smallint    NOT NULL,
    open        time        NOT NULL DEFAULT '00:00:00',
    close       time        NOT NULL DEFAULT '00:00:00',
    "timeZone"  smallint    NOT NULL DEFAULT -5,
    "storeId"   integer,
    CONSTRAINT "PK_hours_operation" PRIMARY KEY (id),
    CONSTRAINT "UQ_hours_operation_store_day" UNIQUE ("storeId", day),
    CONSTRAINT "FK_hours_operation_store" FOREIGN KEY ("storeId") REFERENCES store (id) ON DELETE CASCADE
);

CREATE TABLE product (
    id            serial              NOT NULL,
    name          text                NOT NULL,
    description   text                NOT NULL,
    image         text                NOT NULL,
    type          integer             NOT NULL DEFAULT 1,
    price         double precision    NOT NULL DEFAULT 0,
    "createdAt"   timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"   timestamptz         NOT NULL DEFAULT now(),
    "deletedAt"   timestamp,
    "companyId"   integer,
    CONSTRAINT "PK_product" PRIMARY KEY (id),
    CONSTRAINT "UQ_product_name" UNIQUE (name),
    CONSTRAINT "FK_product_company" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE
);

CREATE TABLE address (
    id           serial       NOT NULL,
    alias        text         NOT NULL,
    address      text         NOT NULL,
    location     point        NOT NULL,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz  NOT NULL DEFAULT now(),
    "deletedAt"  timestamp,
    "userId"     integer,
    CONSTRAINT "PK_address" PRIMARY KEY (id),
    CONSTRAINT "FK_address_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE balance (
    "userId"     integer             NOT NULL,
    balance      double precision    NOT NULL DEFAULT 0,
    profit       double precision    NOT NULL DEFAULT '0.85'::double precision,
    amount       double precision    NOT NULL DEFAULT 0,
    money        double precision    NOT NULL DEFAULT 0,
    "createdAt"  timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz         NOT NULL DEFAULT now(),
    CONSTRAINT "PK_balance" PRIMARY KEY ("userId"),
    CONSTRAINT "FK_balance_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE payment (
    id           serial              NOT NULL,
    money        double precision    NOT NULL,
    status       smallint            NOT NULL DEFAULT 1,
    currency     text                NOT NULL,
    products     json                NOT NULL,
    response     json                NOT NULL,
    "createdAt"  timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz         NOT NULL DEFAULT now(),
    "userId"     integer,
    CONSTRAINT "PK_payment" PRIMARY KEY (id),
    CONSTRAINT "FK_payment_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE credit (
    id               serial              NOT NULL,
    amount           double precision    NOT NULL DEFAULT 0,
    "createdAt"      timestamptz         NOT NULL DEFAULT now(),
    "deliverymanId"  integer,
    CONSTRAINT "PK_credit" PRIMARY KEY (id),
    CONSTRAINT "FK_credit_deliveryman" FOREIGN KEY ("deliverymanId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE session (
    id           serial       NOT NULL,
    "idDevice"   uuid         NOT NULL,
    "tokenPush"  text,
    "isOnline"   boolean      NOT NULL DEFAULT false,
    location     point,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updateAt"   timestamptz  NOT NULL DEFAULT now(),
    "userId"     integer      NOT NULL,
    CONSTRAINT "PK_session" PRIMARY KEY (id),
    CONSTRAINT "UQ_session_tokenPush" UNIQUE ("tokenPush"),
    CONSTRAINT "UQ_session_user_device" UNIQUE ("userId", "idDevice"),
    CONSTRAINT "FK_session_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE CASCADE
);

CREATE TABLE "order" (
    id                          serial              NOT NULL,
    note                        text                NOT NULL,
    address                     text                NOT NULL,
    status                      smallint            NOT NULL DEFAULT 1,
    "scoreDeliveryman"          double precision,
    "scoreClient"               double precision,
    products                    json                NOT NULL,
    "deliveryFee"               double precision    NOT NULL,
    total                       double precision    NOT NULL,
    "deliverymanProfit"         double precision,
    "deliveryAppProfit"         double precision,
    payment                     integer             NOT NULL,
    location                    point               NOT NULL,
    "notificationsDeliveryman"  double precision    NOT NULL DEFAULT 0,
    "notificationsClient"       double precision    NOT NULL DEFAULT 0,
    "orderedAt"                 date                NOT NULL,
    "createdAt"                 timestamptz         NOT NULL DEFAULT now(),
    "storeId"                   integer             NOT NULL,
    "userId"                    integer             NOT NULL,
    "deliverymanId"             integer,
    CONSTRAINT "PK_order" PRIMARY KEY (id),
    CONSTRAINT "FK_order_store" FOREIGN KEY ("storeId") REFERENCES store (id) ON DELETE CASCADE,
    CONSTRAINT "FK_order_user" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL,
    CONSTRAINT "FK_order_deliveryman" FOREIGN KEY ("deliverymanId") REFERENCES "user" (id) ON DELETE SET NULL
);

CREATE TABLE chat (
    id           serial       NOT NULL,
    message      text         NOT NULL,
    type         smallint     NOT NULL,
    status       smallint     NOT NULL DEFAULT 1,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "fromId"     integer      NOT NULL,
    "toId"       integer,
    "orderId"    integer      NOT NULL,
    CONSTRAINT "PK_chat" PRIMARY KEY (id),
    CONSTRAINT "FK_chat_from" FOREIGN KEY ("fromId") REFERENCES "user" (id) ON DELETE CASCADE,
    CONSTRAINT "FK_chat_to" FOREIGN KEY ("toId") REFERENCES "user" (id) ON DELETE CASCADE,
    CONSTRAINT "FK_chat_order" FOREIGN KEY ("orderId") REFERENCES "order" (id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Indices (los GiST son los que usa la busqueda por cercania)
-- -----------------------------------------------------------------------------

CREATE INDEX "IDX_company_location" ON company  USING gist  (location);
CREATE INDEX "IDX_address_location" ON address  USING gist  (location);
CREATE INDEX "IDX_store_location"   ON store    USING gist  (location);
CREATE INDEX "IDX_session_location" ON session  USING gist  (location);
CREATE INDEX "IDX_order_location"   ON "order"  USING gist  (location);
CREATE INDEX "IDX_order_orderedAt"  ON "order"  USING btree ("orderedAt");

-- -----------------------------------------------------------------------------
-- Vistas usadas por client/market
-- -----------------------------------------------------------------------------

CREATE VIEW vw_category AS
    SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location
    FROM public.company AS c
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;

CREATE VIEW vw_company AS
    SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,
    cc."categoryId", ho.open, ho.close, ho."day",
    ( (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME < ho.close) AS "isOpen"
    FROM public.company AS c
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||' H')::INTERVAL));

CREATE VIEW vw_product AS
    SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
    FROM public.product AS p
    INNER JOIN public.company AS cc ON cc.id = p."companyId";

-- -----------------------------------------------------------------------------
-- Comentarios de columnas (heredados de las entidades de TypeORM)
-- -----------------------------------------------------------------------------

COMMENT ON COLUMN balance.balance IS 'Balance of money the deliveryman has to be able to take orders';
COMMENT ON COLUMN balance.profit IS 'Percentage of the value of the shipment. Benefit for the deliveryman';
COMMENT ON COLUMN balance.amount IS 'Amount to be returned to the deliveryman. This value increases when the deliveryman takes orders with electronic payments';
COMMENT ON COLUMN balance.money IS 'Money that the client has to make payments in the APP.';
COMMENT ON COLUMN credit.amount IS 'Amount that the delivery person charged to your balance sheet';
COMMENT ON COLUMN "order"."deliverymanProfit" IS 'Profit the deliveryman by the shipment';
COMMENT ON COLUMN "order"."deliveryAppProfit" IS 'Profit the app by the shipment';
COMMENT ON COLUMN "order".payment IS 'Types Payment';
COMMENT ON COLUMN session."isOnline" IS 'If true. The deliveryman wants to receive orders';
