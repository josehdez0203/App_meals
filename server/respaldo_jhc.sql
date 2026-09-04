SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE address (
    id integer NOT NULL,
    alias text NOT NULL,
    address text NOT NULL,
    location point NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deletedAt" timestamp without time zone,
    "userId" integer
);
ALTER TABLE address OWNER TO postgres;
CREATE SEQUENCE address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE address_id_seq OWNER TO postgres;
ALTER SEQUENCE address_id_seq OWNED BY address.id;
CREATE TABLE balance (
    "userId" integer NOT NULL,
    balance double precision DEFAULT '0'::double precision NOT NULL,
    profit double precision DEFAULT '0.85'::double precision NOT NULL,
    amount double precision DEFAULT '0'::double precision NOT NULL,
    money double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE balance OWNER TO postgres;
-- COMMENT ON COLUMN balance.balance IS 'Balance of money the deliveryman has to be able to take orders';
-- COMMENT ON COLUMN balance.profit IS 'Percentage of the value of the shipment. Benefit for the deliveryman';
-- COMMENT ON COLUMN balance.amount IS 'Amount to be returned to the deliveryman. This value increases when the deliveryman takes orders with electronic payments';
-- COMMENT ON COLUMN balance.money IS 'Money that the client has to make payments in the APP.';
CREATE TABLE category (
    id integer NOT NULL,
    name text NOT NULL,
    image text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE category OWNER TO postgres;
CREATE SEQUENCE category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE category_id_seq OWNER TO postgres;
ALTER SEQUENCE category_id_seq OWNED BY category.id;
CREATE TABLE chat (
    id integer NOT NULL,
    message text NOT NULL,
    type smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "fromId" integer NOT NULL,
    "toId" integer,
    "orderId" integer NOT NULL
);
ALTER TABLE chat OWNER TO postgres;
CREATE SEQUENCE chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE chat_id_seq OWNER TO postgres;
ALTER SEQUENCE chat_id_seq OWNED BY chat.id;
CREATE TABLE company (
    id integer NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    contact text NOT NULL,
    image text DEFAULT ''::text NOT NULL,
    marker text DEFAULT ''::text NOT NULL,
    email text NOT NULL,
    location point NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "userId" integer
);
ALTER TABLE company OWNER TO postgres;
CREATE TABLE company_category (
    id integer NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "companyId" integer NOT NULL,
    "categoryId" integer NOT NULL
);
ALTER TABLE company_category OWNER TO postgres;
CREATE SEQUENCE company_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE company_category_id_seq OWNER TO postgres;
ALTER SEQUENCE company_category_id_seq OWNED BY company_category.id;
CREATE SEQUENCE company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE company_id_seq OWNER TO postgres;
ALTER SEQUENCE company_id_seq OWNED BY company.id;
CREATE TABLE credit (
    id integer NOT NULL,
    amount double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deliverymanId" integer
);
ALTER TABLE credit OWNER TO postgres;
-- COMMENT ON COLUMN credit.amount IS 'Amount that the delivery person charged to your balance sheet';
CREATE SEQUENCE credit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE credit_id_seq OWNER TO postgres;
ALTER SEQUENCE credit_id_seq OWNED BY credit.id;
CREATE TABLE hours_operation (
    id integer NOT NULL,
    day smallint NOT NULL,
    open time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    close time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    "timeZone" smallint DEFAULT '-5'::smallint NOT NULL,
    "storeId" integer
);
ALTER TABLE hours_operation OWNER TO postgres;
CREATE SEQUENCE hours_operation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE hours_operation_id_seq OWNER TO postgres;
ALTER SEQUENCE hours_operation_id_seq OWNED BY hours_operation.id;
CREATE TABLE "order" (
    id integer NOT NULL,
    note text NOT NULL,
    address text NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    "scoreDeliveryman" double precision,
    "scoreClient" double precision,
    products json NOT NULL,
    "deliveryFee" double precision NOT NULL,
    total double precision NOT NULL,
    "deliverymanProfit" double precision,
    "deliveryAppProfit" double precision,
    payment integer NOT NULL,
    location point NOT NULL,
    "notificationsDeliveryman" double precision DEFAULT '0'::double precision NOT NULL,
    "notificationsClient" double precision DEFAULT '0'::double precision NOT NULL,
    "orderedAt" date NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "storeId" integer NOT NULL,
    "userId" integer NOT NULL,
    "deliverymanId" integer
);
ALTER TABLE "order" OWNER TO postgres;
-- COMMENT ON COLUMN "order"."deliverymanProfit" IS 'Profit the deliveryman by the shipment';
-- COMMENT ON COLUMN "order"."deliveryAppProfit" IS 'Profit the app by the shipment';
-- COMMENT ON COLUMN "order".payment IS 'Types Payment';
CREATE SEQUENCE order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE order_id_seq OWNER TO postgres;
ALTER SEQUENCE order_id_seq OWNED BY "order".id;
CREATE TABLE payment (
    id integer NOT NULL,
    money double precision NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    currency text NOT NULL,
    products json NOT NULL,
    response json NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "userId" integer
);
ALTER TABLE payment OWNER TO postgres;
CREATE SEQUENCE payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE payment_id_seq OWNER TO postgres;
ALTER SEQUENCE payment_id_seq OWNED BY payment.id;
CREATE TABLE product (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    image text NOT NULL,
    type integer DEFAULT 1 NOT NULL,
    price double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deletedAt" timestamp without time zone,
    "companyId" integer
);
ALTER TABLE product OWNER TO postgres;
CREATE SEQUENCE product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE product_id_seq OWNER TO postgres;
ALTER SEQUENCE product_id_seq OWNED BY product.id;
CREATE TABLE session (
    id integer NOT NULL,
    "idDevice" uuid NOT NULL,
    "tokenPush" text,
    "isOnline" boolean DEFAULT false NOT NULL,
    location point,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updateAt" timestamp with time zone DEFAULT now() NOT NULL,
    "userId" integer NOT NULL
);
ALTER TABLE session OWNER TO postgres;
-- COMMENT ON COLUMN session."isOnline" IS 'If true. The deliveryman wants to receive orders';
CREATE SEQUENCE session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE session_id_seq OWNER TO postgres;
ALTER SEQUENCE session_id_seq OWNED BY session.id;
CREATE TABLE store (
    id integer NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    contact text NOT NULL,
    email text NOT NULL,
    "startupCost" double precision DEFAULT '1.25'::double precision NOT NULL,
    "costKm" double precision DEFAULT '0.55'::double precision NOT NULL,
    location point NOT NULL,
    sales integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deletedAt" timestamp without time zone,
    "companyId" integer,
    "userId" integer
);
ALTER TABLE store OWNER TO postgres;
CREATE SEQUENCE store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE store_id_seq OWNER TO postgres;
ALTER SEQUENCE store_id_seq OWNED BY store.id;
CREATE TABLE typeorm_metadata (
    type character varying NOT NULL,
    database character varying,
    schema character varying,
    "table" character varying,
    name character varying,
    value text
);
ALTER TABLE typeorm_metadata OWNER TO postgres;
CREATE TABLE "user" (
    id integer NOT NULL,
    "idGoogle" text,
    "fullName" text NOT NULL,
    email text NOT NULL,
    phone text,
    password text NOT NULL,
    "passwordTemporary" text,
    image text DEFAULT ''::text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    roles text[] DEFAULT '{client}'::text[] NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "user" OWNER TO postgres;
CREATE SEQUENCE user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE user_id_seq OWNER TO postgres;
ALTER SEQUENCE user_id_seq OWNED BY "user".id;
CREATE VIEW vw_category AS
 SELECT DISTINCT ON (ct.id) ct.id,
    ct.name,
    ct.image,
    s.location
   FROM (((company c
     JOIN store s ON ((s."companyId" = c.id)))
     JOIN company_category cc ON ((cc."companyId" = c.id)))
     JOIN category ct ON ((cc."categoryId" = ct.id)));
ALTER TABLE vw_category OWNER TO postgres;
CREATE VIEW vw_company AS
 SELECT c.id,
    s.id AS "storeId",
    s.name,
    s.address,
    s.contact,
    c.image,
    s.location,
    cc."categoryId",
    ho.open,
    ho.close,
    ho.day,
    ((((now() + ((ho."timeZone" || ' H'::text))::interval))::time without time zone > ho.open) AND (((now() + ((ho."timeZone" || ' H'::text))::interval))::time without time zone < ho.close)) AS "isOpen"
   FROM (((company c
     JOIN company_category cc ON ((cc."companyId" = c.id)))
     JOIN store s ON ((s."companyId" = c.id)))
     JOIN hours_operation ho ON (((ho."storeId" = s.id) AND ((ho.day)::numeric = EXTRACT(dow FROM (now() + ((ho."timeZone" || ' H'::text))::interval))))));
ALTER TABLE vw_company OWNER TO postgres;
CREATE VIEW vw_product AS
 SELECT p.id,
    p."companyId",
    cc.name AS "companyName",
    p.name,
    p.image,
    p.description,
    p.type,
    p.price
   FROM (product p
     JOIN company cc ON ((cc.id = p."companyId")));
ALTER TABLE vw_product OWNER TO postgres;
ALTER TABLE ONLY address ALTER COLUMN id SET DEFAULT nextval('address_id_seq'::regclass);
ALTER TABLE ONLY category ALTER COLUMN id SET DEFAULT nextval('category_id_seq'::regclass);
ALTER TABLE ONLY chat ALTER COLUMN id SET DEFAULT nextval('chat_id_seq'::regclass);
ALTER TABLE ONLY company ALTER COLUMN id SET DEFAULT nextval('company_id_seq'::regclass);
ALTER TABLE ONLY company_category ALTER COLUMN id SET DEFAULT nextval('company_category_id_seq'::regclass);
ALTER TABLE ONLY credit ALTER COLUMN id SET DEFAULT nextval('credit_id_seq'::regclass);
ALTER TABLE ONLY hours_operation ALTER COLUMN id SET DEFAULT nextval('hours_operation_id_seq'::regclass);
ALTER TABLE ONLY "order" ALTER COLUMN id SET DEFAULT nextval('order_id_seq'::regclass);
ALTER TABLE ONLY payment ALTER COLUMN id SET DEFAULT nextval('payment_id_seq'::regclass);
ALTER TABLE ONLY product ALTER COLUMN id SET DEFAULT nextval('product_id_seq'::regclass);
ALTER TABLE ONLY session ALTER COLUMN id SET DEFAULT nextval('session_id_seq'::regclass);
ALTER TABLE ONLY store ALTER COLUMN id SET DEFAULT nextval('store_id_seq'::regclass);
ALTER TABLE ONLY "user" ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);
ALTER TABLE ONLY company
    ADD CONSTRAINT "PK_056f7854a7afdba7cbd6d45fc20" PRIMARY KEY (id);
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "PK_1031171c13130102495201e3e20" PRIMARY KEY (id);
ALTER TABLE ONLY hours_operation
    ADD CONSTRAINT "PK_50ddf39f58c8ca7bdb33adc1d09" PRIMARY KEY (id);
ALTER TABLE ONLY balance
    ADD CONSTRAINT "PK_9297a70b26dc787156fa49de26b" PRIMARY KEY ("userId");
ALTER TABLE ONLY category
    ADD CONSTRAINT "PK_9c4e4a89e3674fc9f382d733f03" PRIMARY KEY (id);
ALTER TABLE ONLY chat
    ADD CONSTRAINT "PK_9d0b2ba74336710fd31154738a5" PRIMARY KEY (id);
ALTER TABLE ONLY product
    ADD CONSTRAINT "PK_bebc9158e480b949565b4dc7a82" PRIMARY KEY (id);
ALTER TABLE ONLY credit
    ADD CONSTRAINT "PK_c98add8e192ded18b69c3e345a5" PRIMARY KEY (id);
ALTER TABLE ONLY "user"
    ADD CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY (id);
ALTER TABLE ONLY address
    ADD CONSTRAINT "PK_d92de1f82754668b5f5f5dd4fd5" PRIMARY KEY (id);
ALTER TABLE ONLY company_category
    ADD CONSTRAINT "PK_e30c10055c199565d44daa681fa" PRIMARY KEY (id);
ALTER TABLE ONLY store
    ADD CONSTRAINT "PK_f3172007d4de5ae8e7692759d79" PRIMARY KEY (id);
ALTER TABLE ONLY session
    ADD CONSTRAINT "PK_f55da76ac1c3ac420f444d2ff11" PRIMARY KEY (id);
ALTER TABLE ONLY payment
    ADD CONSTRAINT "PK_fcaec7df5adf9cac408c686b2ab" PRIMARY KEY (id);
ALTER TABLE ONLY product
    ADD CONSTRAINT "UQ_22cc43e9a74d7498546e9a63e77" UNIQUE (name);
ALTER TABLE ONLY category
    ADD CONSTRAINT "UQ_23c05c292c439d77b0de816b500" UNIQUE (name);
ALTER TABLE ONLY hours_operation
    ADD CONSTRAINT "UQ_2ea822a45d2b3076c0c97496dfb" UNIQUE ("storeId", day);
ALTER TABLE ONLY company_category
    ADD CONSTRAINT "UQ_49766dca44f61bbd3dadbf85165" UNIQUE ("companyId", "categoryId");
ALTER TABLE ONLY "user"
    ADD CONSTRAINT "UQ_8e1f623798118e629b46a9e6299" UNIQUE (phone);
ALTER TABLE ONLY company
    ADD CONSTRAINT "UQ_a76c5cd486f7779bd9c319afd27" UNIQUE (name);
ALTER TABLE ONLY "user"
    ADD CONSTRAINT "UQ_ad852befaea9884b115b2224d92" UNIQUE ("idGoogle");
ALTER TABLE ONLY session
    ADD CONSTRAINT "UQ_c68cd2e281637a272e7580beb80" UNIQUE ("tokenPush");
ALTER TABLE ONLY "user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE (email);
ALTER TABLE ONLY session
    ADD CONSTRAINT "UQ_fbf10d89fa270d87bf552a51c46" UNIQUE ("userId", "idDevice");
CREATE INDEX "IDX_364715fa9c508e1c379626fb75" ON address USING gist (location);
CREATE INDEX "IDX_73fa941c122465238600d2c4bb" ON "order" USING btree ("orderedAt");
CREATE INDEX "IDX_c4e3631ce2b1257ccd23841ac7" ON store USING gist (location);
CREATE INDEX "IDX_d404d5947fdda6e61e2c87ee08" ON company USING gist (location);
CREATE INDEX "IDX_d7d67335f5f4938ead7d71961f" ON "order" USING gist (location);
CREATE INDEX "IDX_fbb8fa59f720b87ed335c4e6a6" ON session USING gist (location);
ALTER TABLE ONLY hours_operation
    ADD CONSTRAINT "FK_0567736a3f6a1e7bfb396a807a5" FOREIGN KEY ("storeId") REFERENCES store(id) ON DELETE CASCADE;
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "FK_1a79b2f719ecd9f307d62b81093" FOREIGN KEY ("storeId") REFERENCES store(id) ON DELETE CASCADE;
ALTER TABLE ONLY session
    ADD CONSTRAINT "FK_3d2f174ef04fb312fdebd0ddc53" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE CASCADE;
ALTER TABLE ONLY store
    ADD CONSTRAINT "FK_3f82dbf41ae837b8aa0a27d29c3" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY company_category
    ADD CONSTRAINT "FK_42a13d69ef98c1dc9a516e571d9" FOREIGN KEY ("companyId") REFERENCES company(id) ON DELETE CASCADE;
ALTER TABLE ONLY credit
    ADD CONSTRAINT "FK_567a7da9fad88ef063bf806b834" FOREIGN KEY ("deliverymanId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "FK_636e9801600f4b04cc77922a487" FOREIGN KEY ("deliverymanId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY company_category
    ADD CONSTRAINT "FK_8d8defd7a0678e1c51dc3e13da0" FOREIGN KEY ("categoryId") REFERENCES category(id) ON DELETE CASCADE;
ALTER TABLE ONLY balance
    ADD CONSTRAINT "FK_9297a70b26dc787156fa49de26b" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY store
    ADD CONSTRAINT "FK_97c27a2bfe23da8147cccd34a18" FOREIGN KEY ("companyId") REFERENCES company(id) ON DELETE CASCADE;
ALTER TABLE ONLY product
    ADD CONSTRAINT "FK_a331e634b87a7dbba2e7fccce19" FOREIGN KEY ("companyId") REFERENCES company(id) ON DELETE CASCADE;
ALTER TABLE ONLY chat
    ADD CONSTRAINT "FK_ae20ff0cccb54e717d98228ef1a" FOREIGN KEY ("toId") REFERENCES "user"(id) ON DELETE CASCADE;
ALTER TABLE ONLY payment
    ADD CONSTRAINT "FK_b046318e0b341a7f72110b75857" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY chat
    ADD CONSTRAINT "FK_ba7804af40ae366bb3962794a25" FOREIGN KEY ("orderId") REFERENCES "order"(id) ON DELETE CASCADE;
ALTER TABLE ONLY company
    ADD CONSTRAINT "FK_c41a1d36702f2cd0403ce58d33a" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY "order"
    ADD CONSTRAINT "FK_caabe91507b3379c7ba73637b84" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY address
    ADD CONSTRAINT "FK_d25f1ea79e282cc8a42bd616aa3" FOREIGN KEY ("userId") REFERENCES "user"(id) ON DELETE SET NULL;
ALTER TABLE ONLY chat
    ADD CONSTRAINT "FK_fd96a8e76f459215fa900e5649a" FOREIGN KEY ("fromId") REFERENCES "user"(id) ON DELETE CASCADE;
