create table bill (
    id numeric(19,0),
    bill_no varchar(200),
    customer_id numeric(19,0),
    receipt_id numberic(19,0),
    receiver_id numeric(19,0),
    shipper_id numeric(19,0),
    payment_id numeric(19,0),
    order_id numberic(19,0),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence bill_seq;