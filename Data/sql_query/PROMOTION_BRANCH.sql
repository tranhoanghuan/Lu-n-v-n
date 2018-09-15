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

alter table promotion_branch add constraint fk_promotion_branch_branch_id foreign key (branch_id) references branch(id);
alter table promotion_branch add constraint fk_promotion_branch_promotion_id foreign key (promotion_id) references promotion(id);
/