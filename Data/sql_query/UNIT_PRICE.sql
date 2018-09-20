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

alter table unit_price add constraint fk_unit_price_material_id foreign key (material_id) references material(id);
alter table unit_price add constraint fk_unit_price_product_id foreign key (product_id) references product(id);
alter table unit_price add constraint fk_unit_price_service_type_id foreign key (service_type_id) references service_type(id);
alter table unit_price add constraint fk_unit_price_unit_id foreign key (unit_id) references unit(id);