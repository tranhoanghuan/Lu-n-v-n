create table receipt_wash_bag(
    id numeric(19,0) primary key,
    wash_bag_id numeric(19,0),
    receipt_id numeric(19,0),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence receipt_wash_bag_seq;

alter table receipt_wash_bag add constraint fk_receipt_wash_bag_wash_bag_id foreign key (wash_bag_id) references wash_bag(id);
alter table receipt_wash_bag add constraint fk_receipt_wash_bag_receipt_id foreign key (receipt_id) references receipt(id);
