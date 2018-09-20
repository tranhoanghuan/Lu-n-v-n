create table receipt_detail(
    id numeric(19,0) primary key,
    receipt_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence receipt_detail_seq;

alter table receipt_detail add constraint fk_receipt_detail_bill_id foreign key (receipt_id) references receipt(id);
alter table receipt_detail add constraint fk_receipt_detail_service_type_id foreign key (service_type_id) references service_type(id);
alter table receipt_detail add constraint fk_receipt_detail_unit_price_id foreign key (unit_price_id) references unit_price(id);
alter table receipt_detail add constraint fk_receipt_detail_unit_id foreign key (unit_id) references unit(id);
alter table receipt_detail add constraint fk_receipt_detail_label_id foreign key (label_id) references label(id);
alter table receipt_detail add constraint fk_receipt_detail_color_id foreign key (color_id) references color(id);
alter table receipt_detail add constraint fk_receipt_detail_product_id foreign key (product_id) references product(id);
alter table receipt_detail add constraint fk_receipt_detail_material_id foreign key (material_id) references material(id);