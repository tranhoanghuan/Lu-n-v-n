create table service_type(
    id numeric(19,0) primary key,
    service_type_name varchar(2000),
    service_type_desc varchar(4000),
    promotion_id numeric(19,0),
    status varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP
);

create sequence service_type_seq;

alter table service_type add constraint fk_service_type_promotion_id foreign key (promotion_id) references promotion(id);
/