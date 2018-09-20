create table bill (
    id numeric(19,0) primary key,
    bill_no varchar(200),
    receipt_id numeric(19,0),
    receiver_id numeric(19,0),
    shipper_id numeric(19,0),
    payment_id numeric(19,0),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence bill_seq;

alter table bill add constraint fk_bill_payment_id foreign key (payment_id) references payment(id);
alter table bill add constraint fk_bill_shipper_id foreign key (shipper_id) references staff(id);
alter table bill add constraint fk_bill_receiver_id foreign key (receiver_id) references staff(id);
alter table bill add constraint fk_bill_receipt_id foreign key (receipt_id) references receipt(id);

