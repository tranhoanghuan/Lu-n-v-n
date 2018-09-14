create table order (
    id numeric(19,0) primary key,
    order_no varchar(200),
    customer_id numeric(19,0),
    branch_id numeric(19,0),
    receiver_id numeric(19,0),
    shipper_id numeric(19,0),
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

create sequence order_seq;