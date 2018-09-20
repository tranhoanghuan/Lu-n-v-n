create table promotion(
    id numeric(19,0) primary key,
    promotion_name varchar(2000),
    sale numeric(2,0),
    date_start date,
    date_end date,
    promotion_code varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence promotion_seq;
