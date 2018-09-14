create table promotion_branch(

    id numeric(19,0),
    promotion_id numeric(19,0),
    branch_id numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence promotion_branch_seq;