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
	current_status varchar(4000)
);

alter table task add constraint fk_create_by foreign key (create_by) references staff (id);
alter table task add constraint fk_update_by foreign key (update_by) references staff (id);
alter table task add constraint fk_current_staff foreign key (current_staff) references staff (id);
alter table task add constraint fk_previous_staff foreign key (previous_staff) references staff (id);
alter table task add constraint fk_customer_order foreign key (customer_order) references customer_order(id);
alter table task add constraint fk_receipt foreign key (receipt) references receipt(id);