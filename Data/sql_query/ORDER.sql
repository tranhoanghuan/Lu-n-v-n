create table customer_order (
    id numeric(19,0) primary key,
    order_no varchar(200),
    customer_id numeric(19,0),
    branch_id numeric(19,0),
    payment_id numeric(19,0),
    pick_up_date date,
    pick_up_time_id numeric(19,0),
    delivery_date date,
    delivery_time_id numeric(19,0),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence customer_order_seq;

alter table customer_order add constraint fk_customer_order_customer_id foreign key (customer_id) references customer(id);
alter table customer_order add constraint fk_customer_order_branch_id foreign key (branch_id) references branch(id);
alter table customer_order add constraint fk_customer_order_payment_id foreign key (payment_id) references payment(id);
alter table customer_order add constraint fk_customer_order_pick_up_time_id foreign key (pick_up_time_id) references time_schedule(id);
alter table customer_order add constraint fk_customer_order_delivery_time_id foreign key (delivery_time_id) references time_schedule(id);