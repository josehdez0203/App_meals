-- =============================================================================
-- init.sql - Esquema de la base de datos de la API (NestJS + TypeORM)
-- =============================================================================
-- Este archivo es la fuente de verdad versionada del esquema. Se ejecuta
-- automaticamente la PRIMERA vez que se inicializa un volumen vacio de
-- PostgreSQL (via docker-entrypoint-initdb.d), por lo que la aplicacion ya no
-- necesita `synchronize: true` para crear las tablas.
--
-- IMPORTANTE
--   * Solo se ejecuta cuando el directorio de datos esta vacio. Si ya existe
--     `server/postgres/` con datos, este script NO se vuelve a ejecutar.
--   * Al cambiar una entidad de TypeORM hay que actualizar este archivo a mano,
--     porque `DB_SYNCHRONIZE` queda desactivado por defecto.
--   * Requiere PostGIS (los queries usan `ST_DistanceSphere` y `location::geometry`).
--
-- Uso manual (sobre una base vacia):
--   psql -h localhost -U postgres -d jose -f db/init.sql
-- =============================================================================

SET search_path TO public;

-- PostGIS es necesario para los calculos de distancia por geolocalizacion.
CREATE EXTENSION IF NOT EXISTS postgis;

-- -----------------------------------------------------------------------------
-- Tablas (ordenadas por dependencias de claves foraneas)
-- -----------------------------------------------------------------------------

-- user
CREATE TABLE IF NOT EXISTS "user" (
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
    CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY (id),
    CONSTRAINT "UQ_ad852befaea9884b115b2224d92" UNIQUE ("idGoogle"),
    CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE (email),
    CONSTRAINT "UQ_8e1f623798118e629b46a9e6299" UNIQUE (phone)
);

-- category
CREATE TABLE IF NOT EXISTS category (
    id           serial       NOT NULL,
    name         text         NOT NULL,
    image        text         NOT NULL DEFAULT 'https://cdn-icons-png.flaticon.com/512/685/685352.png',
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT "PK_9c4e4a89e3674fc9f382d733f03" PRIMARY KEY (id),
    CONSTRAINT "UQ_23c05c292c439d77b0de816b500" UNIQUE (name)
);

-- company
CREATE TABLE IF NOT EXISTS company (
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
    CONSTRAINT "PK_056f7854a7afdba7cbd6d45fc20" PRIMARY KEY (id),
    CONSTRAINT "UQ_a76c5cd486f7779bd9c319afd27" UNIQUE (name),
    CONSTRAINT "FK_c41a1d36702f2cd0403ce58d33a" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- company_category
CREATE TABLE IF NOT EXISTS company_category (
    id            serial       NOT NULL,
    "updatedAt"   timestamptz  NOT NULL DEFAULT now(),
    "companyId"   integer      NOT NULL,
    "categoryId"  integer      NOT NULL,
    CONSTRAINT "PK_e30c10055c199565d44daa681fa" PRIMARY KEY (id),
    CONSTRAINT "UQ_49766dca44f61bbd3dadbf85165" UNIQUE ("companyId", "categoryId"),
    CONSTRAINT "FK_42a13d69ef98c1dc9a516e571d9" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE,
    CONSTRAINT "FK_8d8defd7a0678e1c51dc3e13da0" FOREIGN KEY ("categoryId") REFERENCES category (id) ON DELETE CASCADE
);

-- store
CREATE TABLE IF NOT EXISTS store (
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
    CONSTRAINT "PK_f3172007d4de5ae8e7692759d79" PRIMARY KEY (id),
    CONSTRAINT "FK_97c27a2bfe23da8147cccd34a18" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE,
    CONSTRAINT "FK_3f82dbf41ae837b8aa0a27d29c3" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- hours_operation
CREATE TABLE IF NOT EXISTS hours_operation (
    id          serial      NOT NULL,
    day         smallint    NOT NULL,
    open        time        NOT NULL DEFAULT '00:00:00',
    close       time        NOT NULL DEFAULT '00:00:00',
    "timeZone"  smallint    NOT NULL DEFAULT -5,
    "storeId"   integer,
    CONSTRAINT "PK_50ddf39f58c8ca7bdb33adc1d09" PRIMARY KEY (id),
    CONSTRAINT "UQ_2ea822a45d2b3076c0c97496dfb" UNIQUE ("storeId", day),
    CONSTRAINT "FK_0567736a3f6a1e7bfb396a807a5" FOREIGN KEY ("storeId") REFERENCES store (id) ON DELETE CASCADE
);

-- product
CREATE TABLE IF NOT EXISTS product (
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
    CONSTRAINT "PK_bebc9158e480b949565b4dc7a82" PRIMARY KEY (id),
    CONSTRAINT "UQ_22cc43e9a74d7498546e9a63e77" UNIQUE (name),
    CONSTRAINT "FK_a331e634b87a7dbba2e7fccce19" FOREIGN KEY ("companyId") REFERENCES company (id) ON DELETE CASCADE
);

-- address
CREATE TABLE IF NOT EXISTS address (
    id           serial       NOT NULL,
    alias        text         NOT NULL,
    address      text         NOT NULL,
    location     point        NOT NULL,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz  NOT NULL DEFAULT now(),
    "deletedAt"  timestamp,
    "userId"     integer,
    CONSTRAINT "PK_d92de1f82754668b5f5f5dd4fd5" PRIMARY KEY (id),
    CONSTRAINT "FK_d25f1ea79e282cc8a42bd616aa3" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- balance
CREATE TABLE IF NOT EXISTS balance (
    "userId"     integer             NOT NULL,
    balance      double precision    NOT NULL DEFAULT 0,
    profit       double precision    NOT NULL DEFAULT '0.85'::double precision,
    amount       double precision    NOT NULL DEFAULT 0,
    money        double precision    NOT NULL DEFAULT 0,
    "createdAt"  timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz         NOT NULL DEFAULT now(),
    CONSTRAINT "PK_9297a70b26dc787156fa49de26b" PRIMARY KEY ("userId"),
    CONSTRAINT "FK_9297a70b26dc787156fa49de26b" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- payment
CREATE TABLE IF NOT EXISTS payment (
    id           serial              NOT NULL,
    money        double precision    NOT NULL,
    status       smallint            NOT NULL DEFAULT 1,
    currency     text                NOT NULL,
    products     json                NOT NULL,
    response     json                NOT NULL,
    "createdAt"  timestamptz         NOT NULL DEFAULT now(),
    "updatedAt"  timestamptz         NOT NULL DEFAULT now(),
    "userId"     integer,
    CONSTRAINT "PK_fcaec7df5adf9cac408c686b2ab" PRIMARY KEY (id),
    CONSTRAINT "FK_b046318e0b341a7f72110b75857" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- credit
CREATE TABLE IF NOT EXISTS credit (
    id               serial              NOT NULL,
    amount           double precision    NOT NULL DEFAULT 0,
    "createdAt"      timestamptz         NOT NULL DEFAULT now(),
    "deliverymanId"  integer,
    CONSTRAINT "PK_c98add8e192ded18b69c3e345a5" PRIMARY KEY (id),
    CONSTRAINT "FK_567a7da9fad88ef063bf806b834" FOREIGN KEY ("deliverymanId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- session
CREATE TABLE IF NOT EXISTS session (
    id           serial       NOT NULL,
    "idDevice"   uuid         NOT NULL,
    "tokenPush"  text,
    "isOnline"   boolean      NOT NULL DEFAULT false,
    location     point,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "updateAt"   timestamptz  NOT NULL DEFAULT now(),
    "userId"     integer      NOT NULL,
    CONSTRAINT "PK_f55da76ac1c3ac420f444d2ff11" PRIMARY KEY (id),
    CONSTRAINT "UQ_c68cd2e281637a272e7580beb80" UNIQUE ("tokenPush"),
    CONSTRAINT "UQ_fbf10d89fa270d87bf552a51c46" UNIQUE ("userId", "idDevice"),
    CONSTRAINT "FK_3d2f174ef04fb312fdebd0ddc53" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE CASCADE
);

-- order
CREATE TABLE IF NOT EXISTS "order" (
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
    CONSTRAINT "PK_1031171c13130102495201e3e20" PRIMARY KEY (id),
    CONSTRAINT "FK_1a79b2f719ecd9f307d62b81093" FOREIGN KEY ("storeId") REFERENCES store (id) ON DELETE CASCADE,
    CONSTRAINT "FK_caabe91507b3379c7ba73637b84" FOREIGN KEY ("userId") REFERENCES "user" (id) ON DELETE SET NULL,
    CONSTRAINT "FK_636e9801600f4b04cc77922a487" FOREIGN KEY ("deliverymanId") REFERENCES "user" (id) ON DELETE SET NULL
);

-- chat
CREATE TABLE IF NOT EXISTS chat (
    id           serial       NOT NULL,
    message      text         NOT NULL,
    type         smallint     NOT NULL,
    status       smallint     NOT NULL DEFAULT 1,
    "createdAt"  timestamptz  NOT NULL DEFAULT now(),
    "fromId"     integer      NOT NULL,
    "toId"       integer,
    "orderId"    integer      NOT NULL,
    CONSTRAINT "PK_9d0b2ba74336710fd31154738a5" PRIMARY KEY (id),
    CONSTRAINT "FK_fd95a8e76f459215fa900e5649a" FOREIGN KEY ("fromId") REFERENCES "user" (id) ON DELETE CASCADE,
    CONSTRAINT "FK_ae20ff0cccb54e717d98228ef1a" FOREIGN KEY ("toId") REFERENCES "user" (id) ON DELETE CASCADE,
    CONSTRAINT "FK_ba7804af40ae366bb3962794a25" FOREIGN KEY ("orderId") REFERENCES "order" (id) ON DELETE CASCADE
);

-- Tabla interna de TypeORM: guarda la definicion de las vistas (@ViewEntity).
CREATE TABLE IF NOT EXISTS typeorm_metadata (
    type      character varying  NOT NULL,
    database  character varying,
    schema    character varying,
    "table"   character varying,
    name      character varying,
    value     text
);

-- -----------------------------------------------------------------------------
-- Indices (los GiST son los que usa la busqueda por cercania)
-- -----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS "IDX_d404d5947fdda6e61e2c87ee08" ON company  USING gist  (location);
CREATE INDEX IF NOT EXISTS "IDX_364715fa9c508e1c379626fb75" ON address  USING gist  (location);
CREATE INDEX IF NOT EXISTS "IDX_c4e3631ce2b1257ccd23841ac7" ON store    USING gist  (location);
CREATE INDEX IF NOT EXISTS "IDX_fbb8fa59f720b87ed335c4e6a6" ON session  USING gist  (location);
CREATE INDEX IF NOT EXISTS "IDX_d7d67335f5f4938ead7d71961f" ON "order"  USING gist  (location);
CREATE INDEX IF NOT EXISTS "IDX_73fa941c122465238600d2c4bb" ON "order"  USING btree ("orderedAt");

-- -----------------------------------------------------------------------------
-- Vistas (@ViewEntity de client/market/views)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_category AS
    SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location
    FROM public.company AS c
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;

CREATE OR REPLACE VIEW vw_company AS
    SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,
    cc."categoryId", ho.open, ho.close, ho."day",
    ( (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME < ho.close) AS "isOpen"
    FROM public.company AS c
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||' H')::INTERVAL));

CREATE OR REPLACE VIEW vw_product AS
    SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
    FROM public.product AS p
    INNER JOIN public.company AS cc ON cc.id = p."companyId";

-- Metadatos de las vistas (los escribe TypeORM; aqui se dejan listos para que
-- un futuro `synchronize: true` no las recree en cada arranque).
INSERT INTO typeorm_metadata (type, database, schema, "table", name, value)
SELECT 'VIEW', NULL, 'public', NULL, 'vw_category', $view$
    SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location
	FROM public.company AS c 
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;
    $view$
WHERE NOT EXISTS (SELECT 1 FROM typeorm_metadata WHERE name = 'vw_category');

INSERT INTO typeorm_metadata (type, database, schema, "table", name, value)
SELECT 'VIEW', NULL, 'public', NULL, 'vw_company', $view$
    SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location, 
    cc."categoryId", ho.open, ho.close, ho."day", 
    ( (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME < ho.close) AS "isOpen"
	FROM public.company AS c 
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||' H')::INTERVAL));
    $view$
WHERE NOT EXISTS (SELECT 1 FROM typeorm_metadata WHERE name = 'vw_company');

INSERT INTO typeorm_metadata (type, database, schema, "table", name, value)
SELECT 'VIEW', NULL, 'public', NULL, 'vw_product', $view$
    SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
	FROM public.product AS p
    INNER JOIN public.company AS cc ON cc.id = p."companyId"
    $view$
WHERE NOT EXISTS (SELECT 1 FROM typeorm_metadata WHERE name = 'vw_product');

-- -----------------------------------------------------------------------------
-- Comentarios declarados en las entidades
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
