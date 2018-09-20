create table time_schedule(
    id numeric(19,0) primary key,
    time_schedule_no varchar(200),
    time_start time,
    time_end time,
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);
create sequence time_schedule_seq;
