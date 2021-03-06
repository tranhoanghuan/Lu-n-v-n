create table receipt (
    id numeric(19,0) primary key,
    customer_id numeric(19,0),
    order_id numeric(19,0),
    receipt_no varchar(200),
    pick_up_time timestamp,
    delivery_time timestamp,
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence receipt_seq;

alter table receipt add constraint fk_receipt_customer_id foreign key (customer_id) references customer(id);
alter table receipt add constraint fk_receipt_order_id foreign key (order_id) references customer_order(id);
