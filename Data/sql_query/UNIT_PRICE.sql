create table unit_price(
    id numeric(19,0) primary key,
    product_id numeric(19,0),
    service_type_id numeric(19,0),
    material_id numeric(19,0),
    unit_id numeric(19,0),
    apply_date timestamp,
    price money,
    max_price money,
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)

);

create sequence unit_price_seq;