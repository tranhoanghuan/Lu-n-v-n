--store
INSERT INTO public.store(
	store_name, address, create_by, update_by, status, store_avatar)
	VALUES ('CAN_THO_STORE', 'Xuan Khanh, Ninh Kieu, Can Tho', 0, 0, 'ACTIVE', 3);
--branch
INSERT INTO public.branch(
	branch_name, store_id, address, create_by, update_by, status, branch_avatar)
	VALUES ('CHI NHANH BINH THUY', 1, 'Ninh Kieu, Can Tho', 0, 0,'ACTIVE',17);

INSERT INTO public.branch(
	branch_name, store_id, address, create_by, update_by, status, branch_avatar)
	VALUES ('CHI NHANH NINH KIEU', 1, 'Ninh Kieu, Can Tho', 0, 0,'ACTIVE',17);

--Washing machine
insert into washing_machine(branch_id, bought_date, capacity, status, washer_code)
select 2, now(), 10, 'ACTIVE', 'WASHER_'||nextVal('washing_machine_seq') from branch
