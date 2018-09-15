create table branch (
    id numeric(19,0) primary key,
    branch_name varchar(2000) not null,
    store_id numeric(19,0) not null,
    address varchar(4000),
    CREATE_BY	NUMERIC(19,0) not null,
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP not null,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);
create sequence branch_seq;
alter table branch add constraint fk_branch_store_id foreign key (store_id) references store(id);