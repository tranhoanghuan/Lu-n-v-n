--Add unit_price in to service_type
alter table service_type add column unit_price_id numeric(19,0);
alter table service_type add CONSTRAINT fk_service_type_unit_price_id foreign key (unit_price_id) REFERENCES unit_price(id);


--change hash_code to hash_codes;
alter table customer drop hash_code;
alter table staff drop hash_code;
alter table customer add column hash_codes varchar(200);
alter table staff add column hash_codes varchar(200);

--Add table for image
create table public.post (
  id serial primary key,
  headline text,
  body text,
  header_image_file text
);
--add image for customer,staff, product,promotion,service,branch,store;

alter table customer add column customer_avatar INTEGER REFERENCES post(id);
alter table staff add column staff_avatar INTEGER REFERENCES post(id);
alter table product add column product_avatar INTEGER REFERENCES post(id);
alter table service_type add column service_type_avatar INTEGER REFERENCES post(id);
alter table branch add column branch_avatar INTEGER REFERENCES post(id);
alter table store add column store_avatar INTEGER REFERENCES post(id);

--for statistics 

create table statistics (

    id serial primary key,
    table_name varchar(4000),
    code varchar(4000),
    st_value varchar(4000),
    st_ext_value varchar(4000),
    CREATE_DATE	TIMESTAMP default now(),
    UPDATE_DATE	TIMESTAMP
);

-- code
--SERVICE_COUNT
--CLOTH COUNT
--PROMOTION_USE_COUNT
--PROMOTION_VALUES
--SCHEDULE_COUNT
--+st_value store time_schedule_no
--+st_value count used times
--PRODUCT_USE_COUNT
--+st_value store id product
--+st_ext_value count used times
--+DRAFT_ORDER
--+SUCCESS_ORDER
--+


-- Set default
alter table service_type add CONSTRAINT fk_service_type_avatar FOREIGN key (service_type_avatar) REFERENCES post(id);

DO
$do$
declare
    tb record;
	full_query text := '';
begin
for tb in SELECT table_name
  FROM information_schema.tables
 WHERE table_schema='public'
   AND table_type='BASE TABLE'
   and table_name not in ('post')
   loop	
   		
   		full_query := 'alter table ' ||  tb.table_name || ' alter column create_date set default now();';
		execute full_query;
		full_query := 'alter table ' ||  tb.table_name || ' alter column update_date set default now();';
		execute full_query;
   end loop;
 end;
$do$

--Add location for Branch
alter table branch add latidute varchar(4000);
alter table branch add longtidute varchar(4000);

--24/10/2018
-- Add column address
alter table customer_order add pick_up_place varchar(4000);
alter table customer_order add delivery_place varchar(4000);
--Add promotion into Order
alter table customer_order add promotion_id numeric(19,0);
alter table customer_order add constraint fk_customer_order_promotion_id foreign key (promotion_id) references promotion (id);

--add foreign key ro product in order detail
alter table order_detail add constraint fk_order_detail_product_id foreign key (product_id) references product (id);

--25/10/2018

alter table order_detail add unit_price numeric(19,0);
alter table order_detail add constraint fk_order_detail_unit_price foreign key (unit_price) references unit_price (id);

alter table receipt_detail add unit_price numeric(19,0);
alter table receipt_detail add constraint fk_receipt_detail_unit_price foreign key (unit_price) references unit_price (id);

alter table receipt add pick_up_date date;
alter table receipt add delivery_date date;
alter table receipt add pick_up_place varchar(4000);
alter table receipt add delivery_place varchar(4000);

alter table receipt_detail add recieved_amount integer;

--26/10/2018
ALTER TABLE public.receipt ADD COLUMN staff_pick_up numeric(19, 0);
alter table public.receipt add constraint  fk_receipt_staff_pick_up foreign key (staff_pick_up) references staff(id);
ALTER TABLE public.receipt ADD COLUMN staff_delivery numeric(19, 0);
alter table public.receipt add constraint  fk_receipt_staff_delivery foreign key (staff_delivery) references staff(id);

create table task (
	id serial,
	create_by numeric(19,0),
	update_by numeric (19,0),
	create_date date default now(),
	update_date date default now(),
	task_type varchar(4000),
	current_staff numeric(19,0),
	previous_staff numeric(19,0),
	customer_order numeric(19,0),
	receipt numeric(19,0),
	previous_status varchar(4000),
	current_status varchar(4000),
  PREVIOUS_TASK varchar(1)
);

alter table task add constraint fk_create_by foreign key (create_by) references staff (id);
alter table task add constraint fk_update_by foreign key (update_by) references staff (id);
alter table task add constraint fk_current_staff foreign key (current_staff) references staff (id);
alter table task add constraint fk_previous_staff foreign key (previous_staff) references staff (id);
alter table task add constraint fk_customer_order foreign key (customer_order) references customer_order(id);
alter table task add constraint fk_receipt foreign key (receipt) references receipt(id);

--29/10/2018
alter table task add branch_id numeric(19,0);
alter table task add constraint task_branch_id foreign key (branch_id) references branch(id);

--02/11/2018
alter table staff_type add staff_code varchar(4000);
--03/11/2018
ALTER TABLE public.receipt
    ALTER COLUMN pick_up_time TYPE time(8) without time zone ;

ALTER TABLE public.receipt
    ALTER COLUMN delivery_time TYPE time(8) without time zone ;

--04/11/2018
alter table public.washing_machine drop column buyer;
alter table public.washing_machine add capacity INTEGER;
alter table public.washing_machine add washer_code varchar(4000);

--07/11/2018
drop table receipt_wash_bag;
alter table wash_bag add receipt_id numeric;
alter table wash_bag add constraint fk_wash_bag_receipt_id foreign key (receipt_id) references receipt (id);


--08/11/2018
-- Type: wash_search

-- DROP TYPE public.wash_search;

-- Type: wash_search

-- DROP TYPE public.wash_search;

CREATE TYPE public.wash_search AS
(
	customer_order_id numeric(19,0),
	receipt_id numeric(19,0),
	wb_name character varying(255),
	washer_code character varying(255),
	status character varying(255),
	customer_name character varying(255)
);

ALTER TYPE public.wash_search
    OWNER TO postgres;

GRANT USAGE ON TYPE public.wash_search TO auth_authenticated;

GRANT USAGE ON TYPE public.wash_search TO postgres;

GRANT USAGE ON TYPE public.wash_search TO PUBLIC;

--09/11/2018
-- Type: info_washer

-- DROP TYPE public.info_washer;

CREATE TYPE public.info_washer AS
(
	id numeric(19,0),
	sum bigint,
	code character varying(255),
	serving numeric(19,0)[],
	pending numeric(19,0)[]
);

ALTER TYPE public.info_washer
    OWNER TO postgres;


--10/11/2018
ALTER TYPE public.wash_search
    ADD ATTRIBUTE sn integer;

--11/11/2018
-- Type: assign_work

-- DROP TYPE public.assign_work;

CREATE TYPE public.assign_work AS
(
	re_id numeric(19,0),
	curr_user numeric(19,0),
	washer_id numeric(19,0),
	sn integer
);

ALTER TYPE public.assign_work
    OWNER TO postgres;

GRANT USAGE ON TYPE public.assign_work TO auth_authenticated;

GRANT USAGE ON TYPE public.assign_work TO postgres;

GRANT USAGE ON TYPE public.assign_work TO PUBLIC;

--14/11/2018
alter table bill_detail add unit_price numeric;
alter table bill_detail add constraint fk_bill_detail_unit_price foreign key (unit_price) references unit_price(id);
GRANT ALL ON SEQUENCE public.bill_seq TO auth_authenticated;
GRANT ALL ON SEQUENCE public.bill_detail_seq TO auth_authenticated;

--15/11/2018
alter table order_detail add weight numeric(19,2);
alter table bill add constraint fk_bill_create_by foreign key (create_by) references staff(id);
alter table bill add constraint fk_bill_update_by foreign key (update_by) references staff(id);


--16/11/2018
alter table receipt add delivery_amount numeric(19,2);
alter table customer_order add confirm_by_customer varchar(4000);

--17/11/2018

create sequence service_product_seq;
create table service_product (
	id numeric(19,0) default nextVal('service_product_seq') primary key,
	service_type_id numeric(19,0),
	product_id numeric (19,0),
	create_date date default now(),
	update_date date default now(),
	create_by numeric (19,0),
	update_by numeric (19,0)
)

alter table service_product add constraint fk_service_product_service_type_id foreign key (service_type_id) references service_type(id);
alter table service_product add constraint fk_service_product_product_id foreign key (product_id) references product(id);
alter table service_product add constraint fk_service_product_create_by foreign key (create_by) references staff(id);
alter table service_product add constraint fk_service_product_update_by foreign key (update_by) references staff(id);

ALTER TABLE public.order_detail
    ALTER COLUMN amount TYPE double precision ;

ALTER TABLE public.receipt_detail
    ALTER COLUMN recieved_amount TYPE double precision ;

ALTER TABLE public.receipt_detail
    ALTER COLUMN delivery_amount TYPE double precision ;

ALTER TABLE public.bill_detail
    ALTER COLUMN amount TYPE double precision ;

ALTER TABLE public.bill_detail
    ADD COLUMN received_amount double precision;

--20/11/2018
-- Table: public.env_var

-- DROP TABLE public.env_var;

create sequence ENV_VAR_pkey;
CREATE TABLE public.env_var
(
    key_name character varying COLLATE pg_catalog."default",
    value_key character varying(255) COLLATE pg_catalog."default",
    id bigint NOT NULL DEFAULT nextval('"ENV_VAR_id_seq"'::regclass),
    CONSTRAINT "ENV_VAR_pkey" PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.env_var
    OWNER to postgres;

GRANT INSERT, SELECT, UPDATE ON TABLE public.env_var TO auth_authenticated;

GRANT ALL ON TABLE public.env_var TO postgres;

--23/11/2018
alter table customer_order add rating integer;
alter table customer_order add comment varchar(4000);