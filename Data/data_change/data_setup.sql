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

insert into service_type_branch(service_type_id, branch_id, status)
select st.id, br.id, 'ACTIVE' from service_type st, branch br where br.id=2 limit 8;