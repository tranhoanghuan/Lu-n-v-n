create table wash_bag_detail(
    id numeric(19,0) primary key,
    wash_bag_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount integer,
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence wash_bag_detail_seq;

alter table wash_bag_detail add constraint fk_wash_bag_detail_bill_id foreign key (wash_bag_id) references wash_bag(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_service_type_id foreign key (service_type_id) references service_type(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_unit_id foreign key (unit_id) references unit(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_label_id foreign key (label_id) references label(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_color_id foreign key (color_id) references color(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_product_id foreign key (product_id) references product(id);
alter table wash_bag_detail add constraint fk_wash_bag_detail_material_id foreign key (material_id) references material(id);