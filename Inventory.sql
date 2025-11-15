--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- Name: f_cost_sum(text); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.f_cost_sum(order_po text) RETURNS numeric
    LANGUAGE sql
    AS $$
select coalesce(sum(order_instance.amount * supplies.cost), 0.00)
from order_instance
join supplies on order_instance.item_number = supplies.item_number
where order_instance.po = order_po;
$$;


ALTER FUNCTION inventory.f_cost_sum(order_po text) OWNER TO postgres;

--
-- Name: f_items_count(text); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.f_items_count(order_po text) RETURNS integer
    LANGUAGE sql
    AS $$
select count(*)
from order_instance
where order_instance.po = order_po;
$$;


ALTER FUNCTION inventory.f_items_count(order_po text) OWNER TO postgres;

--
-- Name: populate_receipt(); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.populate_receipt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if new.receipt is not null then
insert into receipt_instance (receipt, po, item_number, fulfilled)
select new.receipt, oi.po, oi.item_number, oi.amount
from order_instance oi
where oi.po = new.po
on conflict do nothing;
end if;
return new;
end;
$$;


ALTER FUNCTION inventory.populate_receipt() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: department; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.department (
    department character varying(8) NOT NULL,
    contact character varying(50),
    phone character varying(10),
    fax character varying(10)
);


ALTER TABLE inventory.department OWNER TO postgres;

--
-- Name: inventory; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory (
    location character varying(20) NOT NULL,
    room character varying(20),
    item_number character varying(30),
    current_count integer,
    unit character(2),
    max_count integer
);


ALTER TABLE inventory.inventory OWNER TO postgres;

--
-- Name: order_instance; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.order_instance (
    po character varying(20),
    item_number character varying(20),
    amount integer,
    department character varying(8),
    instance integer NOT NULL
);


ALTER TABLE inventory.order_instance OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.orders (
    po character varying(20) NOT NULL,
    order_date date,
    receipt character varying(20)
);


ALTER TABLE inventory.orders OWNER TO postgres;

--
-- Name: orders_instance_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

CREATE SEQUENCE inventory.orders_instance_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE inventory.orders_instance_seq OWNER TO postgres;

--
-- Name: orders_instance_seq; Type: SEQUENCE OWNED BY; Schema: inventory; Owner: postgres
--

ALTER SEQUENCE inventory.orders_instance_seq OWNED BY inventory.order_instance.instance;


--
-- Name: receipt; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.receipt (
    receipt character varying(20) NOT NULL,
    rec_date date,
    rec_materials_mngmt date
);


ALTER TABLE inventory.receipt OWNER TO postgres;

--
-- Name: receipt_instance; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.receipt_instance (
    receipt character varying(20),
    item_number character varying(20),
    fulfilled integer,
    po character varying(20),
    instance integer NOT NULL
);


ALTER TABLE inventory.receipt_instance OWNER TO postgres;

--
-- Name: receipt_instance_instance_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

CREATE SEQUENCE inventory.receipt_instance_instance_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE inventory.receipt_instance_instance_seq OWNER TO postgres;

--
-- Name: receipt_instance_instance_seq; Type: SEQUENCE OWNED BY; Schema: inventory; Owner: postgres
--

ALTER SEQUENCE inventory.receipt_instance_instance_seq OWNED BY inventory.receipt_instance.instance;


--
-- Name: supplies; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.supplies (
    item_number character varying(30) NOT NULL,
    item character varying(50),
    vendor character varying(20),
    unit character(2),
    cost numeric(10,2)
);


ALTER TABLE inventory.supplies OWNER TO postgres;

--
-- Name: v_turn_around; Type: VIEW; Schema: inventory; Owner: postgres
--

CREATE VIEW inventory.v_turn_around AS
 SELECT s.item,
    s.item_number,
    s.vendor,
    o.po,
    ri.receipt,
    (r.rec_date - o.order_date) AS return_time
   FROM ((((inventory.order_instance i
     JOIN inventory.supplies s ON (((s.item_number)::text = (i.item_number)::text)))
     JOIN inventory.orders o ON (((o.po)::text = (i.po)::text)))
     JOIN inventory.receipt_instance ri ON (((ri.po)::text = (o.po)::text)))
     JOIN inventory.receipt r ON (((r.receipt)::text = (ri.receipt)::text)))
  ORDER BY o.order_date DESC;


ALTER VIEW inventory.v_turn_around OWNER TO postgres;

--
-- Name: v_ave_turn_around; Type: VIEW; Schema: inventory; Owner: postgres
--

CREATE VIEW inventory.v_ave_turn_around AS
 SELECT item,
    item_number,
    vendor,
    round(avg(return_time), 1) AS ave_turn_around
   FROM inventory.v_turn_around
  WHERE (return_time > 0)
  GROUP BY item_number, item, vendor
  ORDER BY item, (round(avg(return_time), 1));


ALTER VIEW inventory.v_ave_turn_around OWNER TO postgres;

--
-- Name: v_item_order_history; Type: VIEW; Schema: inventory; Owner: postgres
--

CREATE VIEW inventory.v_item_order_history AS
 SELECT s.item,
    s.item_number,
    s.vendor,
    i.amount,
    i.department,
    o.po,
    o.order_date
   FROM ((inventory.orders o
     JOIN inventory.order_instance i ON (((i.po)::text = (o.po)::text)))
     JOIN inventory.supplies s ON (((s.item_number)::text = (i.item_number)::text)))
  ORDER BY o.order_date DESC, o.po;


ALTER VIEW inventory.v_item_order_history OWNER TO postgres;

--
-- Name: v_last_ordered; Type: VIEW; Schema: inventory; Owner: postgres
--

CREATE VIEW inventory.v_last_ordered AS
SELECT
    NULL::character varying(30) AS item_number,
    NULL::character varying(50) AS item,
    NULL::date AS max_order_date,
    NULL::bigint AS sum;


ALTER VIEW inventory.v_last_ordered OWNER TO postgres;

--
-- Name: v_orders; Type: VIEW; Schema: inventory; Owner: postgres
--

CREATE VIEW inventory.v_orders AS
 SELECT po,
    order_date,
    inventory.f_items_count((po)::text) AS total_items,
    inventory.f_cost_sum((po)::text) AS total_cost
   FROM inventory.orders;


ALTER VIEW inventory.v_orders OWNER TO postgres;

--
-- Name: vendor; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.vendor (
    vendor character varying(20) NOT NULL,
    company_name character varying(50),
    address character varying(70),
    city character varying(50),
    state character(2),
    zip character(5),
    phone character(10),
    contact_first character varying(30),
    contact_last character varying(50)
);


ALTER TABLE inventory.vendor OWNER TO postgres;

--
-- Name: order_instance instance; Type: DEFAULT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.order_instance ALTER COLUMN instance SET DEFAULT nextval('inventory.orders_instance_seq'::regclass);


--
-- Name: receipt_instance instance; Type: DEFAULT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt_instance ALTER COLUMN instance SET DEFAULT nextval('inventory.receipt_instance_instance_seq'::regclass);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (location);


--
-- Name: orders orders_pk; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.orders
    ADD CONSTRAINT orders_pk PRIMARY KEY (po);


--
-- Name: order_instance orders_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.order_instance
    ADD CONSTRAINT orders_pkey PRIMARY KEY (instance);


--
-- Name: receipt_instance receipt_instance_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt_instance
    ADD CONSTRAINT receipt_instance_pkey PRIMARY KEY (instance);


--
-- Name: receipt receipt_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (receipt);


--
-- Name: supplies supplies_pk; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.supplies
    ADD CONSTRAINT supplies_pk PRIMARY KEY (item_number);


--
-- Name: vendor vendor_pk; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.vendor
    ADD CONSTRAINT vendor_pk PRIMARY KEY (vendor);


--
-- Name: v_last_ordered _RETURN; Type: RULE; Schema: inventory; Owner: postgres
--

CREATE OR REPLACE VIEW inventory.v_last_ordered AS
 WITH maxdates AS (
         SELECT s_1.item_number,
            max(o_1.order_date) AS max_order_date
           FROM ((inventory.supplies s_1
             JOIN inventory.order_instance oi_1 ON (((s_1.item_number)::text = (oi_1.item_number)::text)))
             JOIN inventory.orders o_1 ON (((oi_1.po)::text = (o_1.po)::text)))
          GROUP BY s_1.item_number
        )
 SELECT s.item_number,
    s.item,
    md.max_order_date,
    sum(oi.amount) AS sum
   FROM (((inventory.supplies s
     JOIN inventory.order_instance oi ON (((s.item_number)::text = (oi.item_number)::text)))
     JOIN inventory.orders o ON (((oi.po)::text = (o.po)::text)))
     JOIN maxdates md ON ((((s.item_number)::text = (md.item_number)::text) AND (o.order_date = md.max_order_date))))
  GROUP BY s.item_number, md.max_order_date;


--
-- Name: orders order_fulfilled_trigger; Type: TRIGGER; Schema: inventory; Owner: postgres
--

CREATE TRIGGER order_fulfilled_trigger AFTER INSERT OR UPDATE OF receipt ON inventory.orders FOR EACH ROW EXECUTE FUNCTION inventory.populate_receipt();


--
-- Name: orders fk_feceipt; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.orders
    ADD CONSTRAINT fk_feceipt FOREIGN KEY (receipt) REFERENCES inventory.receipt(receipt);


--
-- Name: order_instance fk_oi_department; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.order_instance
    ADD CONSTRAINT fk_oi_department FOREIGN KEY (department) REFERENCES inventory.department(department);


--
-- Name: order_instance fk_oi_item; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.order_instance
    ADD CONSTRAINT fk_oi_item FOREIGN KEY (item_number) REFERENCES inventory.supplies(item_number);


--
-- Name: order_instance fk_oi_po; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.order_instance
    ADD CONSTRAINT fk_oi_po FOREIGN KEY (po) REFERENCES inventory.orders(po);


--
-- Name: inventory item_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory
    ADD CONSTRAINT item_fk FOREIGN KEY (item_number) REFERENCES inventory.supplies(item_number);


--
-- Name: receipt_instance item_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt_instance
    ADD CONSTRAINT item_fk FOREIGN KEY (item_number) REFERENCES inventory.supplies(item_number);


--
-- Name: receipt_instance po_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt_instance
    ADD CONSTRAINT po_fk FOREIGN KEY (po) REFERENCES inventory.orders(po);


--
-- Name: receipt_instance receipt_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.receipt_instance
    ADD CONSTRAINT receipt_fk FOREIGN KEY (receipt) REFERENCES inventory.receipt(receipt);


--
-- Name: supplies vendor_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.supplies
    ADD CONSTRAINT vendor_fk FOREIGN KEY (vendor) REFERENCES inventory.vendor(vendor);


--
-- PostgreSQL database dump complete
--
