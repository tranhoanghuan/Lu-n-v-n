create table washing_machine (
    id numeric (19,0),
    branch_id numeric(19,0),
    washing_machine_no varchar(200),
    bought_date date,
    buyer numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence washing_machine_seq;
/