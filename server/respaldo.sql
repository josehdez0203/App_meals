--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Debian 14.5-1.pgdg110+1)
-- Dumped by pg_dump version 14.5 (Debian 14.5-1.pgdg110+1)

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

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    id integer NOT NULL,
    alias text NOT NULL,
    address text NOT NULL,
    location point NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deletedAt" timestamp without time zone,
    "userId" integer
);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_id_seq OWNER TO postgres;

--
-- Name: address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_id_seq OWNED BY public.address.id;


--
-- Name: balance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balance (
    "userId" integer NOT NULL,
    balance double precision DEFAULT '0'::double precision NOT NULL,
    profit double precision DEFAULT '0.85'::double precision NOT NULL,
    amount double precision DEFAULT '0'::double precision NOT NULL,
    money double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.balance OWNER TO postgres;

--
-- Name: COLUMN balance.balance; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.balance.balance IS 'Balance of money the deliveryman has to be able to take orders';


--
-- Name: COLUMN balance.profit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.balance.profit IS 'Percentage of the value of the shipment. Benefit for the deliveryman';


--
-- Name: COLUMN balance.amount; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.balance.amount IS 'Amount to be returned to the deliveryman. This value increases when the deliveryman takes orders with electronic payments';


--
-- Name: COLUMN balance.money; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.balance.money IS 'Money that the client has to make payments in the APP.';


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name text NOT NULL,
    image text DEFAULT 'https://cdn-icons-png.flaticon.com/512/685/685352.png'::text NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_id_seq OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: chat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat (
    id integer NOT NULL,
    message text NOT NULL,
    type smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "fromId" integer NOT NULL,
    "toId" integer,
    "orderId" integer NOT NULL
);


ALTER TABLE public.chat OWNER TO postgres;

--
-- Name: chat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chat_id_seq OWNER TO postgres;

--
-- Name: chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_id_seq OWNED BY public.chat.id;


--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
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


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: company_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_category (
    id integer NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "companyId" integer NOT NULL,
    "categoryId" integer NOT NULL
);


ALTER TABLE public.company_category OWNER TO postgres;

--
-- Name: company_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.company_category_id_seq OWNER TO postgres;

--
-- Name: company_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_category_id_seq OWNED BY public.company_category.id;


--
-- Name: company_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.company_id_seq OWNER TO postgres;

--
-- Name: company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_id_seq OWNED BY public.company.id;


--
-- Name: credit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit (
    id integer NOT NULL,
    amount double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "deliverymanId" integer
);


ALTER TABLE public.credit OWNER TO postgres;

--
-- Name: COLUMN credit.amount; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.credit.amount IS 'Amount that the delivery person charged to your balance sheet';


--
-- Name: credit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.credit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.credit_id_seq OWNER TO postgres;

--
-- Name: credit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.credit_id_seq OWNED BY public.credit.id;


--
-- Name: hours_operation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hours_operation (
    id integer NOT NULL,
    day smallint NOT NULL,
    open time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    close time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    "timeZone" smallint DEFAULT '-5'::smallint NOT NULL,
    "storeId" integer
);


ALTER TABLE public.hours_operation OWNER TO postgres;

--
-- Name: hours_operation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hours_operation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hours_operation_id_seq OWNER TO postgres;

--
-- Name: hours_operation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hours_operation_id_seq OWNED BY public.hours_operation.id;


--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
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


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: COLUMN "order"."deliverymanProfit"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."order"."deliverymanProfit" IS 'Profit the deliveryman by the shipment';


--
-- Name: COLUMN "order"."deliveryAppProfit"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."order"."deliveryAppProfit" IS 'Profit the app by the shipment';


--
-- Name: COLUMN "order".payment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."order".payment IS 'Types Payment';


--
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_id_seq OWNER TO postgres;

--
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_id_seq OWNED BY public."order".id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
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


ALTER TABLE public.payment OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_id_seq OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
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


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    id integer NOT NULL,
    "idDevice" uuid NOT NULL,
    "tokenPush" text,
    "isOnline" boolean DEFAULT false NOT NULL,
    location point,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updateAt" timestamp with time zone DEFAULT now() NOT NULL,
    "userId" integer NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: COLUMN session."isOnline"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.session."isOnline" IS 'If true. The deliveryman wants to receive orders';


--
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_id_seq OWNER TO postgres;

--
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.session_id_seq OWNED BY public.session.id;


--
-- Name: store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store (
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


ALTER TABLE public.store OWNER TO postgres;

--
-- Name: store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.store_id_seq OWNER TO postgres;

--
-- Name: store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.store_id_seq OWNED BY public.store.id;


--
-- Name: typeorm_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.typeorm_metadata (
    type character varying NOT NULL,
    database character varying,
    schema character varying,
    "table" character varying,
    name character varying,
    value text
);


ALTER TABLE public.typeorm_metadata OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
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


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: vw_category; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_category AS
 SELECT DISTINCT ON (ct.id) ct.id,
    ct.name,
    ct.image,
    s.location
   FROM (((public.company c
     JOIN public.store s ON ((s."companyId" = c.id)))
     JOIN public.company_category cc ON ((cc."companyId" = c.id)))
     JOIN public.category ct ON ((cc."categoryId" = ct.id)));


ALTER TABLE public.vw_category OWNER TO postgres;

--
-- Name: vw_company; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_company AS
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
   FROM (((public.company c
     JOIN public.company_category cc ON ((cc."companyId" = c.id)))
     JOIN public.store s ON ((s."companyId" = c.id)))
     JOIN public.hours_operation ho ON (((ho."storeId" = s.id) AND ((ho.day)::numeric = EXTRACT(dow FROM (now() + ((ho."timeZone" || ' H'::text))::interval))))));


ALTER TABLE public.vw_company OWNER TO postgres;

--
-- Name: vw_product; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_product AS
 SELECT p.id,
    p."companyId",
    cc.name AS "companyName",
    p.name,
    p.image,
    p.description,
    p.type,
    p.price
   FROM (public.product p
     JOIN public.company cc ON ((cc.id = p."companyId")));


ALTER TABLE public.vw_product OWNER TO postgres;

--
-- Name: address id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN id SET DEFAULT nextval('public.address_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: chat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat ALTER COLUMN id SET DEFAULT nextval('public.chat_id_seq'::regclass);


--
-- Name: company id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company ALTER COLUMN id SET DEFAULT nextval('public.company_id_seq'::regclass);


--
-- Name: company_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_category ALTER COLUMN id SET DEFAULT nextval('public.company_category_id_seq'::regclass);


--
-- Name: credit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit ALTER COLUMN id SET DEFAULT nextval('public.credit_id_seq'::regclass);


--
-- Name: hours_operation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours_operation ALTER COLUMN id SET DEFAULT nextval('public.hours_operation_id_seq'::regclass);


--
-- Name: order id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order" ALTER COLUMN id SET DEFAULT nextval('public.order_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: session id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session ALTER COLUMN id SET DEFAULT nextval('public.session_id_seq'::regclass);


--
-- Name: store id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store ALTER COLUMN id SET DEFAULT nextval('public.store_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address (id, alias, address, location, "createdAt", "updatedAt", "deletedAt", "userId") FROM stdin;
\.


--
-- Data for Name: balance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balance ("userId", balance, profit, amount, money, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (id, name, image, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: chat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat (id, message, type, status, "createdAt", "fromId", "toId", "orderId") FROM stdin;
\.


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company (id, name, address, contact, image, marker, email, location, "createdAt", "updatedAt", "userId") FROM stdin;
\.


--
-- Data for Name: company_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_category (id, "updatedAt", "companyId", "categoryId") FROM stdin;
\.


--
-- Data for Name: credit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit (id, amount, "createdAt", "deliverymanId") FROM stdin;
\.


--
-- Data for Name: hours_operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hours_operation (id, day, open, close, "timeZone", "storeId") FROM stdin;
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."order" (id, note, address, status, "scoreDeliveryman", "scoreClient", products, "deliveryFee", total, "deliverymanProfit", "deliveryAppProfit", payment, location, "notificationsDeliveryman", "notificationsClient", "orderedAt", "createdAt", "storeId", "userId", "deliverymanId") FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (id, money, status, currency, products, response, "createdAt", "updatedAt", "userId") FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, name, description, image, type, price, "createdAt", "updatedAt", "deletedAt", "companyId") FROM stdin;
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (id, "idDevice", "tokenPush", "isOnline", location, "createdAt", "updateAt", "userId") FROM stdin;
2	2755873b-d882-4044-9f36-c433e7582a97	TOKEN_PUSH_UNIQUE	f	\N	2026-08-29 16:28:52.172169+00	2026-08-29 16:28:52.172169+00	1
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store (id, name, address, contact, email, "startupCost", "costKm", location, sales, "createdAt", "updatedAt", "deletedAt", "companyId", "userId") FROM stdin;
\.


--
-- Data for Name: typeorm_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.typeorm_metadata (type, database, schema, "table", name, value) FROM stdin;
VIEW	\N	public	\N	vw_product	SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price\n\tFROM public.product AS p\n    INNER JOIN public.company AS cc ON cc.id = p."companyId"
VIEW	\N	public	\N	vw_company	SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location, \n    cc."categoryId", ho.open, ho.close, ho."day", \n    ( (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME < ho.close) AS "isOpen"\n\tFROM public.company AS c \n    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id\n    INNER JOIN public.store AS s ON s."companyId" = c.id\n    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||' H')::INTERVAL));
VIEW	\N	public	\N	vw_category	SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location\n\tFROM public.company AS c \n    INNER JOIN public.store AS s ON s."companyId" = c.id\n    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id\n    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, "idGoogle", "fullName", email, phone, password, "passwordTemporary", image, "isActive", roles, "createdAt", "updatedAt") FROM stdin;
1	\N	Jose Hernandez	jose.client@gmail.com	\N	$2b$04$XKqlb9zo3AYUUK1gdas2z.1t0Bypo2BhgljJVVS9iQ8qNWHzkX9li	\N		t	{client}	2026-08-29 16:28:25.878393+00	2026-08-29 16:28:25.878393+00
\.


--
-- Name: address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_id_seq', 1, false);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_id_seq', 1, false);


--
-- Name: chat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_id_seq', 1, false);


--
-- Name: company_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_category_id_seq', 1, false);


--
-- Name: company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_id_seq', 1, false);


--
-- Name: credit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.credit_id_seq', 1, false);


--
-- Name: hours_operation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hours_operation_id_seq', 1, false);


--
-- Name: order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_id_seq', 1, false);


--
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_id_seq', 1, false);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 1, false);


--
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.session_id_seq', 2, true);


--
-- Name: store_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.store_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 1, true);


--
-- Name: company PK_056f7854a7afdba7cbd6d45fc20; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT "PK_056f7854a7afdba7cbd6d45fc20" PRIMARY KEY (id);


--
-- Name: order PK_1031171c13130102495201e3e20; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "PK_1031171c13130102495201e3e20" PRIMARY KEY (id);


--
-- Name: hours_operation PK_50ddf39f58c8ca7bdb33adc1d09; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours_operation
    ADD CONSTRAINT "PK_50ddf39f58c8ca7bdb33adc1d09" PRIMARY KEY (id);


--
-- Name: balance PK_9297a70b26dc787156fa49de26b; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance
    ADD CONSTRAINT "PK_9297a70b26dc787156fa49de26b" PRIMARY KEY ("userId");


--
-- Name: category PK_9c4e4a89e3674fc9f382d733f03; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT "PK_9c4e4a89e3674fc9f382d733f03" PRIMARY KEY (id);


--
-- Name: chat PK_9d0b2ba74336710fd31154738a5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT "PK_9d0b2ba74336710fd31154738a5" PRIMARY KEY (id);


--
-- Name: product PK_bebc9158e480b949565b4dc7a82; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PK_bebc9158e480b949565b4dc7a82" PRIMARY KEY (id);


--
-- Name: credit PK_c98add8e192ded18b69c3e345a5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit
    ADD CONSTRAINT "PK_c98add8e192ded18b69c3e345a5" PRIMARY KEY (id);


--
-- Name: user PK_cace4a159ff9f2512dd42373760; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY (id);


--
-- Name: address PK_d92de1f82754668b5f5f5dd4fd5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT "PK_d92de1f82754668b5f5f5dd4fd5" PRIMARY KEY (id);


--
-- Name: company_category PK_e30c10055c199565d44daa681fa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_category
    ADD CONSTRAINT "PK_e30c10055c199565d44daa681fa" PRIMARY KEY (id);


--
-- Name: store PK_f3172007d4de5ae8e7692759d79; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "PK_f3172007d4de5ae8e7692759d79" PRIMARY KEY (id);


--
-- Name: session PK_f55da76ac1c3ac420f444d2ff11; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "PK_f55da76ac1c3ac420f444d2ff11" PRIMARY KEY (id);


--
-- Name: payment PK_fcaec7df5adf9cac408c686b2ab; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "PK_fcaec7df5adf9cac408c686b2ab" PRIMARY KEY (id);


--
-- Name: product UQ_22cc43e9a74d7498546e9a63e77; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "UQ_22cc43e9a74d7498546e9a63e77" UNIQUE (name);


--
-- Name: category UQ_23c05c292c439d77b0de816b500; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT "UQ_23c05c292c439d77b0de816b500" UNIQUE (name);


--
-- Name: hours_operation UQ_2ea822a45d2b3076c0c97496dfb; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours_operation
    ADD CONSTRAINT "UQ_2ea822a45d2b3076c0c97496dfb" UNIQUE ("storeId", day);


--
-- Name: company_category UQ_49766dca44f61bbd3dadbf85165; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_category
    ADD CONSTRAINT "UQ_49766dca44f61bbd3dadbf85165" UNIQUE ("companyId", "categoryId");


--
-- Name: user UQ_8e1f623798118e629b46a9e6299; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_8e1f623798118e629b46a9e6299" UNIQUE (phone);


--
-- Name: company UQ_a76c5cd486f7779bd9c319afd27; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT "UQ_a76c5cd486f7779bd9c319afd27" UNIQUE (name);


--
-- Name: user UQ_ad852befaea9884b115b2224d92; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_ad852befaea9884b115b2224d92" UNIQUE ("idGoogle");


--
-- Name: session UQ_c68cd2e281637a272e7580beb80; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "UQ_c68cd2e281637a272e7580beb80" UNIQUE ("tokenPush");


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e22; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE (email);


--
-- Name: session UQ_fbf10d89fa270d87bf552a51c46; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "UQ_fbf10d89fa270d87bf552a51c46" UNIQUE ("userId", "idDevice");


--
-- Name: IDX_364715fa9c508e1c379626fb75; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_364715fa9c508e1c379626fb75" ON public.address USING gist (location);


--
-- Name: IDX_73fa941c122465238600d2c4bb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_73fa941c122465238600d2c4bb" ON public."order" USING btree ("orderedAt");


--
-- Name: IDX_c4e3631ce2b1257ccd23841ac7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_c4e3631ce2b1257ccd23841ac7" ON public.store USING gist (location);


--
-- Name: IDX_d404d5947fdda6e61e2c87ee08; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_d404d5947fdda6e61e2c87ee08" ON public.company USING gist (location);


--
-- Name: IDX_d7d67335f5f4938ead7d71961f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_d7d67335f5f4938ead7d71961f" ON public."order" USING gist (location);


--
-- Name: IDX_fbb8fa59f720b87ed335c4e6a6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fbb8fa59f720b87ed335c4e6a6" ON public.session USING gist (location);


--
-- Name: hours_operation FK_0567736a3f6a1e7bfb396a807a5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours_operation
    ADD CONSTRAINT "FK_0567736a3f6a1e7bfb396a807a5" FOREIGN KEY ("storeId") REFERENCES public.store(id) ON DELETE CASCADE;


--
-- Name: order FK_1a79b2f719ecd9f307d62b81093; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_1a79b2f719ecd9f307d62b81093" FOREIGN KEY ("storeId") REFERENCES public.store(id) ON DELETE CASCADE;


--
-- Name: session FK_3d2f174ef04fb312fdebd0ddc53; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "FK_3d2f174ef04fb312fdebd0ddc53" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: store FK_3f82dbf41ae837b8aa0a27d29c3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "FK_3f82dbf41ae837b8aa0a27d29c3" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: company_category FK_42a13d69ef98c1dc9a516e571d9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_category
    ADD CONSTRAINT "FK_42a13d69ef98c1dc9a516e571d9" FOREIGN KEY ("companyId") REFERENCES public.company(id) ON DELETE CASCADE;


--
-- Name: credit FK_567a7da9fad88ef063bf806b834; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit
    ADD CONSTRAINT "FK_567a7da9fad88ef063bf806b834" FOREIGN KEY ("deliverymanId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: order FK_636e9801600f4b04cc77922a487; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_636e9801600f4b04cc77922a487" FOREIGN KEY ("deliverymanId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: company_category FK_8d8defd7a0678e1c51dc3e13da0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_category
    ADD CONSTRAINT "FK_8d8defd7a0678e1c51dc3e13da0" FOREIGN KEY ("categoryId") REFERENCES public.category(id) ON DELETE CASCADE;


--
-- Name: balance FK_9297a70b26dc787156fa49de26b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance
    ADD CONSTRAINT "FK_9297a70b26dc787156fa49de26b" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: store FK_97c27a2bfe23da8147cccd34a18; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT "FK_97c27a2bfe23da8147cccd34a18" FOREIGN KEY ("companyId") REFERENCES public.company(id) ON DELETE CASCADE;


--
-- Name: product FK_a331e634b87a7dbba2e7fccce19; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_a331e634b87a7dbba2e7fccce19" FOREIGN KEY ("companyId") REFERENCES public.company(id) ON DELETE CASCADE;


--
-- Name: chat FK_ae20ff0cccb54e717d98228ef1a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT "FK_ae20ff0cccb54e717d98228ef1a" FOREIGN KEY ("toId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: payment FK_b046318e0b341a7f72110b75857; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT "FK_b046318e0b341a7f72110b75857" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: chat FK_ba7804af40ae366bb3962794a25; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT "FK_ba7804af40ae366bb3962794a25" FOREIGN KEY ("orderId") REFERENCES public."order"(id) ON DELETE CASCADE;


--
-- Name: company FK_c41a1d36702f2cd0403ce58d33a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT "FK_c41a1d36702f2cd0403ce58d33a" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: order FK_caabe91507b3379c7ba73637b84; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "FK_caabe91507b3379c7ba73637b84" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: address FK_d25f1ea79e282cc8a42bd616aa3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT "FK_d25f1ea79e282cc8a42bd616aa3" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: chat FK_fd95a8e76f459215fa900e5649a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT "FK_fd95a8e76f459215fa900e5649a" FOREIGN KEY ("fromId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

