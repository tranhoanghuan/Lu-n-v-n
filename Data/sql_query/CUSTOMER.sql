create table customer(
    id numeric(19,0) primary key,
    full_name varchar(2000),
    email varchar(4000),
    username varchar(4000),
    customer_no varchar(4000),
    password varchar(4000),
    gender boolean,
    address varchar(4000),
    phone varchar(4000),
    status boolean, --hoat dong true, khong hoat dong false
    hash_code varchar(4000),
    lock_status boolean, --true bi khoa, false open
    lock_time  integer,
    timelock timestamp,
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
);
create  sequence customer_seq;
