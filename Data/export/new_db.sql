PGDMP                     
    v            db_21102018    10.4    10.4 �   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    29282    db_21102018    DATABASE     �   CREATE DATABASE db_21102018 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
    DROP DATABASE db_21102018;
             postgres    false                        2615    29283    auth_public    SCHEMA        CREATE SCHEMA auth_public;
    DROP SCHEMA auth_public;
             postgres    false            �           0    0    SCHEMA auth_public    ACL     �   GRANT USAGE ON SCHEMA auth_public TO auth_anonymous;
GRANT ALL ON SCHEMA auth_public TO auth_authenticated;
GRANT ALL ON SCHEMA auth_public TO PUBLIC;
                  postgres    false    11                        2615    47187    postgraphile_watch    SCHEMA     "   CREATE SCHEMA postgraphile_watch;
     DROP SCHEMA postgraphile_watch;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    5            �           0    0    SCHEMA public    ACL     4   GRANT USAGE ON SCHEMA public TO auth_authenticated;
                  postgres    false    5                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    29285    citext 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
    DROP EXTENSION citext;
                  false    5            �           0    0    EXTENSION citext    COMMENT     S   COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';
                       false    3                        3079    29371    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    5            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    2            �           1247    29410    jwt    TYPE     R   CREATE TYPE auth_public.jwt AS (
	role text,
	user_id integer,
	user_type text
);
    DROP TYPE auth_public.jwt;
       auth_public       postgres    false    11            �           1247    38896    assign_work    TYPE     }   CREATE TYPE public.assign_work AS (
	re_id numeric(19,0),
	curr_user numeric(19,0),
	washer_id numeric(19,0),
	sn integer
);
    DROP TYPE public.assign_work;
       public       postgres    false    5            �           0    0    TYPE assign_work    ACL     <   GRANT ALL ON TYPE public.assign_work TO auth_authenticated;
            public       postgres    false    937            �           1247    38863    info_washer    TYPE     �   CREATE TYPE public.info_washer AS (
	id numeric(19,0),
	sum bigint,
	code character varying(255),
	serving numeric(19,0)[],
	pending numeric(19,0)[]
);
    DROP TYPE public.info_washer;
       public       postgres    false    5            �           1247    38770    wash_search    TYPE     �   CREATE TYPE public.wash_search AS (
	customer_order_id numeric(19,0),
	receipt_id numeric(19,0),
	wb_name character varying(255),
	washer_code character varying(255),
	status character varying(255),
	customer_name character varying(255),
	sn integer
);
    DROP TYPE public.wash_search;
       public       postgres    false    5            �           0    0    TYPE wash_search    ACL     <   GRANT ALL ON TYPE public.wash_search TO auth_authenticated;
            public       postgres    false    932                       1255    29411    authenticate(text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.authenticate(email text, password text, user_type text) RETURNS auth_public.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$ 
DECLARE 
  account public.customer; 
BEGIN
    if user_type = 'customer_type' then
        SELECT a.* INTO account 
        FROM public.customer as a 
        WHERE a.email = $1;
    elseif user_type= 'staff_type' then
        SELECT a.* INTO account 
        FROM public.staff as a 
        WHERE a.email = $1;
    end if;
  if account.password = crypt(password, account.password) then 
    return ('auth_authenticated', account.id,user_type )::auth_public.jwt; 
  else 
    return null; 
  end if; 
END; 
$_$;
 S   DROP FUNCTION auth_public.authenticate(email text, password text, user_type text);
       auth_public       postgres    false    1    11    695            �           0    0 @   FUNCTION authenticate(email text, password text, user_type text)    ACL     �   GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_authenticated;
            auth_public       postgres    false    280            �            1259    29412    user    TABLE     U  CREATE TABLE auth_public."user" (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text,
    created_at timestamp without time zone DEFAULT now(),
    user_type text,
    CONSTRAINT user_first_name_check CHECK ((char_length(first_name) < 80)),
    CONSTRAINT user_last_name_check CHECK ((char_length(last_name) < 80))
);
    DROP TABLE auth_public."user";
       auth_public         postgres    false    11            �           0    0    TABLE "user"    ACL     �   GRANT SELECT ON TABLE auth_public."user" TO auth_anonymous;
GRANT SELECT,DELETE,UPDATE ON TABLE auth_public."user" TO auth_authenticated;
GRANT SELECT,INSERT,REFERENCES,TRIGGER ON TABLE auth_public."user" TO PUBLIC;
            auth_public       postgres    false    201            �           1255    29421    current_user()    FUNCTION     �   CREATE FUNCTION auth_public."current_user"() RETURNS auth_public."user"
    LANGUAGE sql STABLE
    AS $$ 
  SELECT * 
  FROM auth_public.user 
  WHERE id = auth_public.current_user_id()
$$;
 ,   DROP FUNCTION auth_public."current_user"();
       auth_public       postgres    false    201    11            �           0    0    FUNCTION "current_user"()    ACL     �   GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_authenticated;
            auth_public       postgres    false    395                       1255    29422    current_user_id()    FUNCTION     �   CREATE FUNCTION auth_public.current_user_id() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  SELECT current_setting('jwt.claims.user_id', true)::integer;
$$;
 -   DROP FUNCTION auth_public.current_user_id();
       auth_public       postgres    false    11            q           1255    29423 +   register_user(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) RETURNS auth_public."user"
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$ 
DECLARE 
  new_user auth_public.user;
  avai_user Integer; 
BEGIN

    if user_type = 'customer_type'
            then
        SELECT a.id INTO avai_user  FROM public.customer as a  WHERE a.email = $3;        
        ELSEIF user_type = 'staff_type' then 
        SELECT a.id INTO avai_user  FROM public.staff as a  WHERE a.email = $3;  
    end if;

    if avai_user is null then
    INSERT INTO auth_public.user (first_name, last_name,user_type) values 
        (first_name, last_name,user_type) 
        returning * INTO new_user; 
        if user_type = 'customer_type'
            then
                INSERT INTO public.customer (id, email, password) values (new_user.id, email, crypt(password, gen_salt('bf')));
        ELSEIF user_type = 'staff_type'
            then INSERT INTO public.staff (id, email, password) values (new_user.id, email, crypt(password, gen_salt('bf')));
        end if;
    end if;   
    if new_user is not null then
        return new_user;
    else
        return null;
    end if; 
END; 
$_$;
 u   DROP FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text);
       auth_public       postgres    false    201    11    1            �           0    0 b   FUNCTION register_user(first_name text, last_name text, email text, user_type text, password text)    ACL     "  GRANT ALL ON FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) TO auth_authenticated;
            auth_public       postgres    false    369            !           1255    47188    notify_watchers_ddl()    FUNCTION     �  CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'ddl',
      'payload',
      (select json_agg(json_build_object('schema', schema_name, 'command', command_tag)) from pg_event_trigger_ddl_commands() as x)
    )::text
  );
end;
$$;
 8   DROP FUNCTION postgraphile_watch.notify_watchers_ddl();
       postgraphile_watch       postgres    false    1    7            h           1255    47189    notify_watchers_drop()    FUNCTION     _  CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'drop',
      'payload',
      (select json_agg(distinct x.schema_name) from pg_event_trigger_dropped_objects() as x)
    )::text
  );
end;
$$;
 9   DROP FUNCTION postgraphile_watch.notify_watchers_drop();
       postgraphile_watch       postgres    false    7    1            Z           1255    38796 %   assign_auto_to_wash(numeric, numeric)    FUNCTION     	  CREATE FUNCTION public.assign_auto_to_wash(br_id numeric, curr_user numeric) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare
	success boolean = false;
	re_id numeric[];
	service_type_list numeric[];
	color_group_list numeric[];
	new_wb_id numeric;
	i_re numeric;
	i_sv numeric;
	item_rd_sv numeric[];
	i_rd_sv numeric;
	item_rd_cl numeric[];
	i_rd_cl numeric;
	coun integer;
begin
	re_id = ARRAY(select re.id from receipt re inner join customer_order co on co.id = re.order_id where co.branch_id =  br_id and co.status = 'PENDING_SERVING');
	foreach i_re in array re_id loop
		begin
			select count(*) into coun from wash_bag where receipt_id = i_re;
			if coun = 0 then 
			begin
			service_type_list = ARRAY (select distinct service_type_id from receipt_detail where receipt_id = i_re);
			foreach i_sv in array service_type_list loop
				begin
					color_group_list = ARRAY(select distinct cg.id from receipt_detail rd 
											 inner join color cl on rd.color_id = cl.id
											 inner join color_group cg on cg.id = cl.color_group_id
											 where receipt_id = i_re and service_type_id = i_sv 
											 and rd.id in (select receipt_detail.id from receipt_detail where receipt_detail.receipt_id = i_re and receipt_detail.service_type_id = i_sv ));
					foreach i_rd_cl in array color_group_list loop
					begin
						new_wb_id = nextVal('wash_bag_seq');
						insert into wash_bag (id, wash_bag_name, create_by, update_by, status, receipt_id)
						values (new_wb_id, 'WB_'||new_wb_id, curr_user,curr_user, 'ACTIVE',i_re );
						
						insert into wash_bag_detail (wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id,
													material_id, amount, create_by, update_by, status)
						select new_wb_id, i_sv, rd.unit_id, rd.label_id,rd.color_id, rd.product_id,rd.material_id,
						 rd.amount, curr_user, curr_user, 'ACTIVE' from receipt_detail rd
						 inner join color cl on rd.color_id = cl.id
						 inner join color_group cg on cg.id = cl.color_group_id
						 and cg.id = i_rd_cl
						 and rd.id in (select receipt_detail.id from receipt_detail where receipt_detail.receipt_id = i_re and receipt_detail.service_type_id = i_sv);
					end;
					end loop;
				 
				end;
			end loop;
		end; end if;
		end;
														  
	end loop;
	return success = true;
end;

$$;
 L   DROP FUNCTION public.assign_auto_to_wash(br_id numeric, curr_user numeric);
       public       postgres    false    5    1            �           0    0 >   FUNCTION assign_auto_to_wash(br_id numeric, curr_user numeric)    ACL     |   GRANT ALL ON FUNCTION public.assign_auto_to_wash(br_id numeric, curr_user numeric) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    346            �            1259    29577    receipt_seq    SEQUENCE     t   CREATE SEQUENCE public.receipt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.receipt_seq;
       public       postgres    false    5            �           0    0    SEQUENCE receipt_seq    ACL     @   GRANT ALL ON SEQUENCE public.receipt_seq TO auth_authenticated;
            public       postgres    false    237            �            1259    29579    receipt    TABLE     �  CREATE TABLE public.receipt (
    id numeric(19,0) DEFAULT nextval('public.receipt_seq'::regclass) NOT NULL,
    order_id numeric(19,0),
    pick_up_time time(6) without time zone,
    delivery_time time(6) without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    pick_up_date date,
    delivery_date date,
    pick_up_place character varying(4000),
    delivery_place character varying(4000),
    staff_pick_up numeric(19,0),
    staff_delivery numeric(19,0),
    delivery_amount numeric(19,2)
);
    DROP TABLE public.receipt;
       public         postgres    false    237    5            �           0    0    TABLE receipt    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    238                       1255    38754 )   assign_to_wash(numeric, numeric, numeric)    FUNCTION     #  CREATE FUNCTION public.assign_to_wash(re_id numeric, curr_user numeric, washer_id numeric) RETURNS public.receipt
    LANGUAGE plpgsql
    AS $$

declare
	wb_list numeric[];
	i numeric;
	r receipt;
	coun numeric;
	sn_max integer;
begin
	wb_list = ARRAY(select id from wash_bag where receipt_id = re_id);
	select count(*) into coun from wash where wash_bag_id in (select id from wash_bag where receipt_id = re_id) and status != 'PENDING_SERVING';
	if coun = 0 then
	begin
		delete from wash where wash_bag_id in (select id from wash_bag where receipt_id = re_id) and status = 'PENDING_SERVING';
		select max(sn) into sn_max from wash where washing_machine_id = washer_id and status = 'PENDING_SERVING';
		if sn_max is null then
			sn_max = 0;
		end if;
		foreach i in array wb_list loop
			insert into wash (wash_bag_id, washing_machine_id, create_by, update_by, status,sn)
			values (i,washer_id,curr_user,curr_user,'PENDING_SERVING',sn_max + 1);
		end loop;
		select * into r from receipt where id = re_id;
		return r;
	end;
	end if;
	return null;
end;

$$;
 Z   DROP FUNCTION public.assign_to_wash(re_id numeric, curr_user numeric, washer_id numeric);
       public       postgres    false    5    1    238            �           0    0 L   FUNCTION assign_to_wash(re_id numeric, curr_user numeric, washer_id numeric)    ACL     �   GRANT ALL ON FUNCTION public.assign_to_wash(re_id numeric, curr_user numeric, washer_id numeric) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    286            (           1255    38900 -   assign_type_one_to_wash(public.assign_work[])    FUNCTION     R  CREATE FUNCTION public.assign_type_one_to_wash(list public.assign_work[]) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare
	i assign_work;
	success boolean = false;
begin
	foreach i in array list loop
	begin
		perform assign_to_wash (i.re_id, i.curr_user,i.washer_id);
		success = true;
	end;
	end loop;
	return success;
end;

$$;
 I   DROP FUNCTION public.assign_type_one_to_wash(list public.assign_work[]);
       public       postgres    false    937    1    5            �           0    0 ;   FUNCTION assign_type_one_to_wash(list public.assign_work[])    ACL     y   GRANT ALL ON FUNCTION public.assign_type_one_to_wash(list public.assign_work[]) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    296            i           1255    39023    clarify_wash(numeric, numeric)    FUNCTION       CREATE FUNCTION public.clarify_wash(r_id numeric, curr_user numeric) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare
	success boolean = false;
	service_type_list numeric[];
	color_group_list numeric[];
	new_wb_id numeric;
	r_id numeric;
	i_sv numeric;
	item_rd_sv numeric[];
	i_rd_sv numeric;
	item_rd_cl numeric[];
	i_rd_cl numeric;
	coun integer;
begin
			select count(*) into coun from wash_bag where receipt_id = r_id;
			if coun = 0 then 
			begin
			service_type_list = ARRAY (select distinct service_type_id from receipt_detail where receipt_id = r_id);
			foreach i_sv in array service_type_list loop
				begin
					color_group_list = ARRAY(select distinct cg.id from receipt_detail rd 
											 inner join color cl on rd.color_id = cl.id
											 inner join color_group cg on cg.id = cl.color_group_id
											 where receipt_id = r_id and service_type_id = i_sv 
											 and rd.id in (select receipt_detail.id from receipt_detail where receipt_detail.receipt_id = r_id and receipt_detail.service_type_id = i_sv ));
					foreach i_rd_cl in array color_group_list loop
					begin
						new_wb_id = nextVal('wash_bag_seq');
						insert into wash_bag (id, wash_bag_name, create_by, update_by, status, receipt_id)
						values (new_wb_id, 'WB_'||new_wb_id, curr_user,curr_user, 'ACTIVE',r_id );
						
						insert into wash_bag_detail (wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id,
													material_id, amount, create_by, update_by, status)
						select new_wb_id, i_sv, rd.unit_id, rd.label_id,rd.color_id, rd.product_id,rd.material_id,
						 rd.amount, curr_user, curr_user, 'ACTIVE' from receipt_detail rd
						 inner join color cl on rd.color_id = cl.id
						 inner join color_group cg on cg.id = cl.color_group_id
						 and cg.id = i_rd_cl
						 and rd.id in (select receipt_detail.id from receipt_detail where receipt_detail.receipt_id = r_id and receipt_detail.service_type_id = i_sv);
					end;
					end loop;
				 
				end;
			end loop;
		end; end if;
		success = true;
	return success;
end;

$$;
 D   DROP FUNCTION public.clarify_wash(r_id numeric, curr_user numeric);
       public       postgres    false    1    5            �           0    0 6   FUNCTION clarify_wash(r_id numeric, curr_user numeric)    ACL     t   GRANT ALL ON FUNCTION public.clarify_wash(r_id numeric, curr_user numeric) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    361            �            1259    29470    customer_seq    SEQUENCE     u   CREATE SEQUENCE public.customer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.customer_seq;
       public       postgres    false    5            �            1259    29472    customer    TABLE     �  CREATE TABLE public.customer (
    id numeric(19,0) DEFAULT nextval('public.customer_seq'::regclass) NOT NULL,
    full_name character varying(2000),
    email character varying(4000),
    username character varying(4000),
    password character varying(4000),
    gender boolean,
    address character varying(4000),
    phone character varying(4000),
    status boolean,
    hash_codes character varying(4000),
    lock_status boolean,
    lock_time integer,
    timelock timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    customer_avatar integer
);
    DROP TABLE public.customer;
       public         postgres    false    213    5            �           0    0    TABLE customer    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.customer TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    214            �            1259    29479    customer_order_seq    SEQUENCE     {   CREATE SEQUENCE public.customer_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.customer_order_seq;
       public       postgres    false    5            �           0    0    SEQUENCE customer_order_seq    ACL     G   GRANT ALL ON SEQUENCE public.customer_order_seq TO auth_authenticated;
            public       postgres    false    215            �            1259    29481    customer_order    TABLE     �  CREATE TABLE public.customer_order (
    id numeric(19,0) DEFAULT nextval('public.customer_order_seq'::regclass) NOT NULL,
    customer_id numeric(19,0),
    branch_id numeric(19,0),
    pick_up_date date,
    pick_up_time_id numeric(19,0),
    delivery_date date,
    delivery_time_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    pick_up_place character varying(4000),
    delivery_place character varying(4000),
    promotion_id numeric(19,0),
    confirm_by_customer character varying(4000)
);
 "   DROP TABLE public.customer_order;
       public         postgres    false    215    5            �           0    0    TABLE customer_order    ACL     v   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.customer_order TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    216            �            1259    29518    order_detail_seq    SEQUENCE     y   CREATE SEQUENCE public.order_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.order_detail_seq;
       public       postgres    false    5            �           0    0    SEQUENCE order_detail_seq    ACL     E   GRANT ALL ON SEQUENCE public.order_detail_seq TO auth_authenticated;
            public       postgres    false    223            �            1259    29520    order_detail    TABLE     �  CREATE TABLE public.order_detail (
    id numeric(19,0) DEFAULT nextval('public.order_detail_seq'::regclass) NOT NULL,
    order_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount double precision,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    unit_price numeric(19,0),
    weight numeric(19,2)
);
     DROP TABLE public.order_detail;
       public         postgres    false    223    5            �           0    0    TABLE order_detail    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.order_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    224            |           1255    38620 Z   create_cus_order_and_detail(public.customer, public.customer_order, public.order_detail[])    FUNCTION     �  CREATE FUNCTION public.create_cus_order_and_detail(cus public.customer, o public.customer_order, d public.order_detail[]) RETURNS public.customer_order
    LANGUAGE plpgsql
    AS $$

declare
  	i order_detail;
	avai_customer customer;
	new_user auth_public.user;
	unit_price numeric;
begin

	select * into avai_customer from customer c where c.email = cus.email;
	o.customer_id = avai_customer.id;
	if avai_customer is null then
	begin
		new_user = auth_public."register_user" (cus.full_name, ' ', cus.email, 'customer_type','password1');
		update customer set (full_name, phone, status, create_by, update_by) = (cus.full_name, cus.phone,true, cus.create_by, cus.update_by) where id = new_user.id;
		o.customer_id = new_user.id;

	end;
	end if;
	
  o.id = nextval('customer_order_seq');
  o.create_date = now();
  o.update_date = now();
	o.status='DRAFT';
  insert into customer_order values (o.*) returning * into o;
	
  foreach i in array d loop
    i.id = nextval('order_detail_seq');
	i.status = 'DRAFT';
	select id into unit_price
	from unit_price
	where product_id = i.product_id
	and service_type_id = i.service_type_id 
	and unit_id = i.unit_id
	and apply_date = (select max(apply_date) from unit_price
	where product_id = i.product_id
	and service_type_id = i.service_type_id 
	and unit_id = i.unit_id
	and status = 'ACTIVE');
	i.unit_price = unit_price;
    i.order_id = o.id;
	i.create_date = now();
  	i.update_date = now();
    insert into order_detail values (i.*);
  end loop;
  return o;
end;

$$;
 y   DROP FUNCTION public.create_cus_order_and_detail(cus public.customer, o public.customer_order, d public.order_detail[]);
       public       postgres    false    1    224    216    214    216    5            �           0    0 k   FUNCTION create_cus_order_and_detail(cus public.customer, o public.customer_order, d public.order_detail[])    ACL     �   GRANT ALL ON FUNCTION public.create_cus_order_and_detail(cus public.customer, o public.customer_order, d public.order_detail[]) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    380            O           1255    30171 E   create_order_and_detail(public.customer_order, public.order_detail[])    FUNCTION     /  CREATE FUNCTION public.create_order_and_detail(o public.customer_order, d public.order_detail[]) RETURNS public.customer_order
    LANGUAGE plpgsql
    AS $$
declare
  i order_detail;
begin
  o.id = nextval('customer_order_seq');
  o.create_date = now();
  o.update_date = now();
  insert into customer_order values (o.*) returning * into o;
  foreach i in array d loop
    i.id = nextval('order_detail_seq');
    i.order_id = o.id;
	i.create_date = now();
  	i.update_date = now();
    insert into order_detail values (i.*);
  end loop;
  return o;
end;
$$;
 `   DROP FUNCTION public.create_order_and_detail(o public.customer_order, d public.order_detail[]);
       public       postgres    false    5    1    216    216    224            �           0    0 R   FUNCTION create_order_and_detail(o public.customer_order, d public.order_detail[])    ACL     �   GRANT ALL ON FUNCTION public.create_order_and_detail(o public.customer_order, d public.order_detail[]) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    335                       1259    29667    wash_bag_detail_seq    SEQUENCE     |   CREATE SEQUENCE public.wash_bag_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.wash_bag_detail_seq;
       public       postgres    false    5            �           0    0    SEQUENCE wash_bag_detail_seq    ACL     H   GRANT ALL ON SEQUENCE public.wash_bag_detail_seq TO auth_authenticated;
            public       postgres    false    262                       1259    29669    wash_bag_detail    TABLE     8  CREATE TABLE public.wash_bag_detail (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_detail_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount integer,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
 #   DROP TABLE public.wash_bag_detail;
       public         postgres    false    262    5            �           0    0    TABLE wash_bag_detail    ACL     �   GRANT DELETE ON TABLE public.wash_bag_detail TO auth_authenticated;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    263            7           1255    38743 R   create_wash_bag_for_receipt(numeric, numeric, numeric[], public.wash_bag_detail[])    FUNCTION     �  CREATE FUNCTION public.create_wash_bag_for_receipt(re_id numeric, curr_user numeric, wash_code numeric[], wb public.wash_bag_detail[]) RETURNS public.receipt
    LANGUAGE plpgsql
    AS $$

declare
	rec receipt;
	new_id numeric;
	e wash_bag_detail;
	i numeric;
begin
	foreach i in array wash_code loop
	begin
		new_id = nextVal('wash_bag_seq');
		insert into wash_bag values (new_id, 'WB_'||new_id,curr_user,curr_user, now(), now(), 'ACTIVE', re_id);
		foreach e in array wb loop
		begin
			if e.wash_bag_id = i then
				insert into wash_bag_detail (wash_bag_id, service_type_id, unit_id, label_id, 
											 color_id, product_id, material_id, amount,create_by, update_by, status)
											 values (new_id, e.service_type_id, e.unit_id, e.label_id, e.color_id,
													e.product_id, e.material_id, e.amount, curr_user, curr_user, 'ACTIVE');
			end if;
		end;
		end loop;
	end;
	end loop;
	select * into rec from receipt where id = re_id;
	return rec;
end;

$$;
 �   DROP FUNCTION public.create_wash_bag_for_receipt(re_id numeric, curr_user numeric, wash_code numeric[], wb public.wash_bag_detail[]);
       public       postgres    false    238    263    5    1            �           0    0 x   FUNCTION create_wash_bag_for_receipt(re_id numeric, curr_user numeric, wash_code numeric[], wb public.wash_bag_detail[])    ACL     �   GRANT ALL ON FUNCTION public.create_wash_bag_for_receipt(re_id numeric, curr_user numeric, wash_code numeric[], wb public.wash_bag_detail[]) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    311            �            1259    29428    bill_seq    SEQUENCE     q   CREATE SEQUENCE public.bill_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.bill_seq;
       public       postgres    false    5            �           0    0    SEQUENCE bill_seq    ACL     =   GRANT ALL ON SEQUENCE public.bill_seq TO auth_authenticated;
            public       postgres    false    203            �            1259    29430    bill    TABLE     �  CREATE TABLE public.bill (
    id numeric(19,0) DEFAULT nextval('public.bill_seq'::regclass) NOT NULL,
    receipt_id numeric(19,0),
    create_id numeric(19,0),
    shipper_id numeric(19,0),
    payment_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.bill;
       public         postgres    false    203    5            �           0    0 
   TABLE bill    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.bill TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    204            V           1255    38917    generate_bill(numeric, numeric)    FUNCTION     {  CREATE FUNCTION public.generate_bill(co_id numeric, curr_user numeric) RETURNS public.bill
    LANGUAGE plpgsql
    AS $$

declare
  re receipt;
  rd receipt_detail;
  new_bill_id numeric;
  wb_id numeric[];
  i numeric;
  co customer_order;
  res bill;
begin
	select * into co from customer_order where id = co_id;
	select * into re from receipt where order_id = co.id;
	new_bill_id = nextVal('bill_seq');
	
	insert into bill (id, receipt_id, create_by, update_by, status)
	values (new_bill_id, re.id,curr_user,curr_user,'PENDING_PAYING');
	
	foreach i in array ARRAY(select id from receipt_detail where receipt_id = re.id) loop
	begin
	select * into rd from receipt_detail where id = i;
	insert into bill_detail(bill_id, service_type_id, unit_id,unit_price, label_id, color_id, 
						   product_id, material_id,received_amount, create_by, update_by, status)
	values (new_bill_id, rd.service_type_id, rd.unit_id, rd.unit_price, rd.label_id, rd.color_id, 
			rd.product_id, rd.material_id,rd.recieved_amount, curr_user,curr_user , 'PENDING_PAYING');
	end;
	end loop;
	select * into res from bill where receipt_id = re.id;
  return res;
end;

$$;
 F   DROP FUNCTION public.generate_bill(co_id numeric, curr_user numeric);
       public       postgres    false    204    1    5            �           0    0 8   FUNCTION generate_bill(co_id numeric, curr_user numeric)    ACL     d   GRANT ALL ON FUNCTION public.generate_bill(co_id numeric, curr_user numeric) TO auth_authenticated;
            public       postgres    false    342                        1255    38872    get_info_washer(numeric)    FUNCTION     e  CREATE FUNCTION public.get_info_washer(br_id numeric) RETURNS SETOF public.info_washer
    LANGUAGE sql STABLE
    AS $$

	select wa.id,
	(select count (*) from (select distinct re.id from receipt re inner join customer_order co on co.id = re.order_id
							inner join wash_bag wb on re.id = wb.receipt_id
							left join wash w on w.wash_bag_id = wb.id
							inner join washing_machine wm on wm.id = w.washing_machine_id
							where co.branch_id =  2 and co.status in  ('PENDING_SERVING','SERVING') and wm.id= wa.id ) sumcount ) as sumCount ,
	wa.washer_code,
	ARRAY(select distinct co.id from receipt re inner join customer_order co on co.id = re.order_id
							inner join wash_bag wb on re.id = wb.receipt_id
							left join wash w on w.wash_bag_id = wb.id
							inner join washing_machine wm on wm.id = w.washing_machine_id
							where co.branch_id =  2 and co.status in  ('SERVING') and wm.id= wa.id ) as serving,
	ARRAY(select distinct co.id from receipt re inner join customer_order co on co.id = re.order_id
							inner join wash_bag wb on re.id = wb.receipt_id
							left join wash w on w.wash_bag_id = wb.id
							inner join washing_machine wm on wm.id = w.washing_machine_id
							where co.branch_id =  2 and co.status in  ('PENDING_SERVING') and wm.id= wa.id ) as pending
	 from washing_machine wa where  wa.branch_id = br_id and wa.status = 'ACTIVE';

$$;
 5   DROP FUNCTION public.get_info_washer(br_id numeric);
       public       postgres    false    5    929            �           1255    38953     get_min_time_for_handle(numeric)    FUNCTION     X  CREATE FUNCTION public.get_min_time_for_handle(br_id numeric) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$

select case when date_part('hour', min_time.max_time_for_handle) > 17 or date_part('hour', min_time.max_time_for_handle)< 6
then
	min_time.max_time_for_handle + interval '12 hours'
else 
	min_time.max_time_for_handle
end
as max_time_for_handle
from 
  (select case when min(sum) = 0 then
		 	(LOCALTIMESTAMP + interval '5 hour')
			else
				(LOCALTIMESTAMP + min(sum) * interval '5 hour')
			end
  as max_time_for_handle from get_info_washer(br_id) )as min_time

$$;
 =   DROP FUNCTION public.get_min_time_for_handle(br_id numeric);
       public       postgres    false    5            ,           1255    30307 .   getamountoforderbycustomerid(numeric, numeric)    FUNCTION     s  CREATE FUNCTION public.getamountoforderbycustomerid(customerid numeric, customerorder numeric) RETURNS money
    LANGUAGE sql STABLE
    AS $$
  SELECT SUM(od.amount)::float8::numeric::money from customer cu
 inner join customer_order co on cu.id = co.customer_id
 left join order_detail od on co.id = od.order_id
 where cu.id = customerId and co.id = customerOrder;
$$;
 ^   DROP FUNCTION public.getamountoforderbycustomerid(customerid numeric, customerorder numeric);
       public       postgres    false    5                        1259    29649    unit_price_seq    SEQUENCE     w   CREATE SEQUENCE public.unit_price_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.unit_price_seq;
       public       postgres    false    5                       1259    29651 
   unit_price    TABLE        CREATE TABLE public.unit_price (
    id numeric(19,0) DEFAULT nextval('public.unit_price_seq'::regclass) NOT NULL,
    product_id numeric(19,0),
    service_type_id numeric(19,0),
    material_id numeric(19,0),
    unit_id numeric(19,0),
    apply_date timestamp without time zone,
    price money,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.unit_price;
       public         postgres    false    256    5            �           0    0    TABLE unit_price    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit_price TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    257            8           1255    38888 (   getlistproductprice(public.unit_price[])    FUNCTION     �  CREATE FUNCTION public.getlistproductprice(unitprice public.unit_price[]) RETURNS public.unit_price[]
    LANGUAGE plpgsql
    AS $$

declare
	res unit_price[];
	i unit_price;
	new_unit_price unit_price;
begin
	foreach i in array unitPrice loop
		select * into new_unit_price from getProductPrice (i);
		res = array_append(res,new_unit_price);								   
   end loop;
	return res;												 
end;
												
									   

$$;
 I   DROP FUNCTION public.getlistproductprice(unitprice public.unit_price[]);
       public       postgres    false    5    257    257    1            ]           1255    38703    getprepareorderserving(numeric)    FUNCTION     ?  CREATE FUNCTION public.getprepareorderserving(br_id numeric) RETURNS SETOF public.receipt
    LANGUAGE sql STABLE
    AS $$

    select r.* from receipt r 
    inner join customer_order co on co.id  = r.order_id 
    where co.status = 'PENDING_SERVING' 
    and r.status = 'RECEIVED'
    and co.branch_id = br_id;

$$;
 <   DROP FUNCTION public.getprepareorderserving(br_id numeric);
       public       postgres    false    238    5            w           1255    38806 "   getproductprice(public.unit_price)    FUNCTION        CREATE FUNCTION public.getproductprice(unitprice public.unit_price) RETURNS public.unit_price
    LANGUAGE sql STABLE
    AS $$

    select *
	from unit_price
	where (product_id = unitPrice.product_id or unitPrice.product_id is null)
	and service_type_id = unitPrice.service_type_id 
	and unit_id = unitPrice.unit_id
	and apply_date = (select max(apply_date) from unit_price
	where product_id = unitPrice.product_id
	and service_type_id = unitPrice.service_type_id 
	and unit_id = unitPrice.unit_id
	and status = 'ACTIVE');
  
$$;
 C   DROP FUNCTION public.getproductprice(unitprice public.unit_price);
       public       postgres    false    257    257    5            b           1255    38691 9   searchcustomerorders(character varying, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.searchcustomerorders(customer_name character varying, customer_order numeric, branch numeric) RETURNS SETOF public.customer_order
    LANGUAGE sql
    AS $$

	select co.* from customer_order co left join customer cus on cus.id = co.customer_id
	where (UPPER(cus.full_name) ilike  '%'||UPPER(customer_name)||'%' or customer_name is null)
	and ( co.id = customer_order or customer_order is null)
	and co.branch_id = branch;

 $$;
 t   DROP FUNCTION public.searchcustomerorders(customer_name character varying, customer_order numeric, branch numeric);
       public       postgres    false    216    5            5           1255    38825    sorted_order_list(numeric)    FUNCTION     �  CREATE FUNCTION public.sorted_order_list(br_id numeric) RETURNS SETOF public.customer_order
    LANGUAGE sql STABLE
    AS $$

 select co.* from customer_order co
	where co.branch_id = br_id  and co.status = 'PENDING_SERVING' 
	and co.id not in (select distinct co.id from receipt re inner join customer_order co on co.id = re.order_id
							inner join wash_bag wb on re.id = wb.receipt_id
							left join wash w on w.wash_bag_id = wb.id
							inner join washing_machine wm on wm.id = w.washing_machine_id
							where co.branch_id =  2 and co.status in  ('PENDING_SERVING','SERVING') and wm.status ='ACTIVE')
	order by co.delivery_date ASC, co.delivery_time_id ASC

$$;
 7   DROP FUNCTION public.sorted_order_list(br_id numeric);
       public       postgres    false    216    5            �            1259    29434    bill_detail_seq    SEQUENCE     x   CREATE SEQUENCE public.bill_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.bill_detail_seq;
       public       postgres    false    5            �           0    0    SEQUENCE bill_detail_seq    ACL     D   GRANT ALL ON SEQUENCE public.bill_detail_seq TO auth_authenticated;
            public       postgres    false    205            �            1259    29436    bill_detail    TABLE     �  CREATE TABLE public.bill_detail (
    id numeric(19,0) DEFAULT nextval('public.bill_detail_seq'::regclass) NOT NULL,
    bill_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount double precision,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    unit_price numeric,
    received_amount double precision
);
    DROP TABLE public.bill_detail;
       public         postgres    false    205    5            �           0    0    TABLE bill_detail    ACL     s   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.bill_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    206            l           1255    47174 5   update_amount_bill(public.bill, public.bill_detail[])    FUNCTION     ]  CREATE FUNCTION public.update_amount_bill(p_b public.bill, bd public.bill_detail[]) RETURNS public.bill
    LANGUAGE plpgsql
    AS $$

declare
  i bill_detail;
  b bill;
begin
	select bi.* into b from bill bi where bi.id = p_b.id;

	update bill set (update_by, update_date,status)
	= (p_b.update_by, now(), 'UPDATED');			   

	select bi.* into b from bill bi where bi.id = p_b.id;
  	foreach i in array bd loop
		i.update_date = now();
		update bill_detail set (status,amount, update_by, update_date)
		= ('UPDATED',i.amount,i.update_by,i.update_date) where id = i.id;
  	end loop;
  return b;
end;

$$;
 S   DROP FUNCTION public.update_amount_bill(p_b public.bill, bd public.bill_detail[]);
       public       postgres    false    1    204    204    5    206            �           0    0 E   FUNCTION update_amount_bill(p_b public.bill, bd public.bill_detail[])    ACL     q   GRANT ALL ON FUNCTION public.update_amount_bill(p_b public.bill, bd public.bill_detail[]) TO auth_authenticated;
            public       postgres    false    364                       1259    29673    washing_machine_seq    SEQUENCE     |   CREATE SEQUENCE public.washing_machine_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.washing_machine_seq;
       public       postgres    false    5            	           1259    29675    washing_machine    TABLE     �  CREATE TABLE public.washing_machine (
    id numeric(19,0) DEFAULT nextval('public.washing_machine_seq'::regclass) NOT NULL,
    branch_id numeric(19,0),
    bought_date date,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    capacity integer,
    washer_code character varying(4000)
);
 #   DROP TABLE public.washing_machine;
       public         postgres    false    264    5            �           0    0    TABLE washing_machine    ACL     w   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.washing_machine TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    265            &           1255    47196 .   update_serving_wash(numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_serving_wash(br_id numeric, curr_user numeric, washer_id numeric) RETURNS public.washing_machine
    LANGUAGE plpgsql
    AS $$

declare
	wash washing_machine;
	co_id numeric;
begin
	select distinct co.id into co_id from customer_order co 
	inner join receipt re on re.order_id = co.id 
	left join wash_bag wb on wb.receipt_id = re.id
	left join wash w on w.wash_bag_id = wb.id
	where w.washing_machine_id = washer_id and w.status = 'SERVING';
	delete from wash where washing_machine_id = washer_id and status in('SERVING','PENDING_SERVING') ;
	delete from wash where washing_machine_id in (select id from washing_machine where status = 'ACTIVE' and branch_id = br_id)
	and status = 'PENDING_SERVING';
	if co_id IS NULL then
	else
		PERFORM updatestatuscustomerorder (co_id, 'PENDING_SERVING',curr_user );
	end if;
	select * into wash from washing_machine where id = washer_id;
	return wash;
end;

$$;
 _   DROP FUNCTION public.update_serving_wash(br_id numeric, curr_user numeric, washer_id numeric);
       public       postgres    false    265    5    1            �           0    0 Q   FUNCTION update_serving_wash(br_id numeric, curr_user numeric, washer_id numeric)    ACL     �   GRANT ALL ON FUNCTION public.update_serving_wash(br_id numeric, curr_user numeric, washer_id numeric) TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    294            K           1255    38791 7   update_status_wash(numeric, character varying, numeric)    FUNCTION     W  CREATE FUNCTION public.update_status_wash(co_id numeric, stt character varying, update_user numeric) RETURNS public.customer_order
    LANGUAGE plpgsql
    AS $$

declare
  co customer_order;
  re receipt;
  i numeric;
  wb_id numeric[];
begin
	select * into co from customer_order where id = co_id;
	select * into re from receipt where order_id = co.id;
	wb_id = ARRAY(select id from wash_bag where receipt_id  = re.id);
	foreach i in array wb_id loop
	begin
		update wash set (status,update_by, update_date) = (stt,update_user,now()) where wash_bag_id = i;
	end;
	end loop;
  return co;
end;

$$;
 d   DROP FUNCTION public.update_status_wash(co_id numeric, stt character varying, update_user numeric);
       public       postgres    false    5    1    216            �           0    0 V   FUNCTION update_status_wash(co_id numeric, stt character varying, update_user numeric)    ACL     �   GRANT ALL ON FUNCTION public.update_status_wash(co_id numeric, stt character varying, update_user numeric) TO auth_authenticated;
            public       postgres    false    331            �            1259    29583    receipt_detail    TABLE     �  CREATE TABLE public.receipt_detail (
    id numeric(19,0) DEFAULT nextval('public.receipt_detail'::regclass) NOT NULL,
    receipt_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount double precision,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    recieved_amount double precision,
    unit_price numeric(19,0),
    delivery_amount double precision
);
 "   DROP TABLE public.receipt_detail;
       public         postgres    false    5            �           0    0    TABLE receipt_detail    ACL     v   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    239            A           1255    30272 ?   updatereceiptanddetail(public.receipt, public.receipt_detail[])    FUNCTION     �  CREATE FUNCTION public.updatereceiptanddetail(p_re public.receipt, rd public.receipt_detail[]) RETURNS public.receipt
    LANGUAGE plpgsql
    AS $$

declare
  i receipt_detail;
  r receipt;
begin
	select re.* into r from receipt re where re.id = p_re.id;

	update receipt set (pick_up_time, delivery_time, update_by, update_date,  pick_up_date,
					   delivery_date, pick_up_place, delivery_place)
	= (p_re.pick_up_time, p_re.delivery_time, p_re.update_by, p_re.update_date,  p_re.pick_up_date,
					   p_re.delivery_date, p_re.pick_up_place, p_re.delivery_place);			   

	select re.* into r from receipt re where re.id = p_re.id;
  	foreach i in array rd loop
		i.update_date = now();
		update receipt_detail set (recieved_amount,delivery_amount,  update_by, update_date)
		= (i.recieved_amount,i.delivery_amount, i.update_by,i.update_date) where id = i.id;
  	end loop;
  return r;
end;

$$;
 ^   DROP FUNCTION public.updatereceiptanddetail(p_re public.receipt, rd public.receipt_detail[]);
       public       postgres    false    238    239    5    1    238            �           0    0 P   FUNCTION updatereceiptanddetail(p_re public.receipt, rd public.receipt_detail[])    ACL     |   GRANT ALL ON FUNCTION public.updatereceiptanddetail(p_re public.receipt, rd public.receipt_detail[]) TO auth_authenticated;
            public       postgres    false    321            0           1255    30397 >   updatestatuscustomerorder(numeric, character varying, numeric)    FUNCTION     �	  CREATE FUNCTION public.updatestatuscustomerorder(co_id numeric, p_status character varying, p_user numeric) RETURNS public.customer_order
    LANGUAGE plpgsql
    AS $$

declare
	o customer_order;
	receipt_id numeric;
	no_rec numeric;
	r receipt;
	co_status varchar;
	task_order task;
begin
	select status into co_status from customer_order co where co.id = co_id;
	update customer_order co set status = p_status where co.id = co_id;
	update customer_order co set update_date = now() where co.id = co_id;
	update order_detail od set status = p_status where od.order_id = co_id;
	update order_detail od set update_date = now() where od.order_id = co_id;
	select co.*  into o from customer_order co where co.id = co_id;
	select * into task_order from task where task_type='TASK_CUSTOMER_ORDER' and customer_order = o.id;
	update task set PREVIOUS_TASK = 'Y' where task_type='TASK_CUSTOMER_ORDER' and customer_order = o.id;
	insert into task (current_staff, previous_staff, task_type, customer_order, receipt, previous_status, current_status,PREVIOUS_TASK, branch_id)
		values (p_user, task_order.current_staff, 'TASK_CUSTOMER_ORDER', o.id, null, co_status, o.status, 'N', o.branch_id);
	if o.status = 'APPROVED' then
		begin
			receipt_id = nextval ('receipt_seq');
			insert into receipt (id, order_id, status, create_by, update_by)
			values (receipt_id,o.id, 'PENDING', p_user,p_user) returning * into r;
			insert into task (current_staff, previous_staff, task_type, customer_order, receipt, previous_status, current_status,PREVIOUS_TASK, branch_id)
			values (p_user, null, 'TASK_RECEIPT', null,receipt_id , null, r.status,'N',o.branch_id );
			select count(1) into no_rec from order_detail where order_id  = o.id;
			if no_rec> 0 then
			begin
				insert into receipt_detail (
					id, receipt_id, service_type_id, unit_id, label_id,
					color_id, product_id, material_id, amount,create_by, update_by, status,unit_price)
				select nextval('receipt_detail_seq'),receipt_id, service_type_id, unit_id, label_id,
					color_id, product_id, material_id, amount,p_user, p_user, 'PENDING', unit_price
				from order_detail where order_id  = o.id;	
			end;
			end if;
		end;
	elsif o.status = 'FINISHED_SERVING' then
		begin
		select * into r from receipt where order_id = o.id;
		PERFORM updatestatusreceipt(r.id,'PENDING_DELIVERY', p_user);
		end;
	end if;
	if o.status = 'PENDING_SERVING' or o.status = 'SERVING' or o.status = 'FINISHED_SERVING' then
		PERFORM update_status_wash (o.id,o.status, p_user );
	end if;
  return o;
end;

$$;
 k   DROP FUNCTION public.updatestatuscustomerorder(co_id numeric, p_status character varying, p_user numeric);
       public       postgres    false    216    5    1            �           0    0 ]   FUNCTION updatestatuscustomerorder(co_id numeric, p_status character varying, p_user numeric)    ACL     �   GRANT ALL ON FUNCTION public.updatestatuscustomerorder(co_id numeric, p_status character varying, p_user numeric) TO auth_authenticated;
            public       postgres    false    304            m           1255    30398 8   updatestatusreceipt(numeric, character varying, numeric)    FUNCTION       CREATE FUNCTION public.updatestatusreceipt(r_id numeric, p_status character varying, p_user numeric) RETURNS public.receipt
    LANGUAGE plpgsql
    AS $$

declare
	no_rec numeric;
	r receipt;
	r_status varchar;
	r_task task;
	branch numeric;
	washer_list info_washer;
begin
	select re.* into r from receipt re where re.id = r_id;
	select branch_id into branch from customer_order co inner join receipt re on re.order_id = co.id where re.id = r.id;
	r_status := r.status;
	select * into r_task from task where task_type = 'TASK_RECEIPT' and receipt = r_id;
	update task set PREVIOUS_TASK = 'Y' where task_type = 'TASK_RECEIPT' and receipt = r_id;
	update receipt set (status,update_date,update_by) = (p_status, now(),p_user) where id  = r_id;
	update receipt_detail set (status,update_date,update_by) = (p_status, now(),p_user) where receipt_id  = r_id;
	insert into task (current_staff, previous_staff, task_type, customer_order, receipt, previous_status, current_status,PREVIOUS_TASK, branch_id)
		values (p_user, r_task.current_staff, 'TASK_RECEIPT', null,r.id , r_task.current_status, p_status,'N', branch);
	select * into r from receipt  where id = r_id;
	if r.status = 'RECEIVED' then
	begin
		PERFORM  updatestatuscustomerorder (r.order_id,'PENDING_SERVING',p_user );
		PERFORM assign_auto_to_wash (branch, r.create_by);
		select * into washer_list from get_info_washer(branch) where sum = (select min(sum) from get_info_washer(branch));
		PERFORM assign_to_wash (r.id, r.create_by, washer_list.id);
	end;
	ELSIF r.status = 'DELIVERIED' then
		PERFORM  updatestatuscustomerorder (r.order_id,'FINISHED',p_user );
		update bill set status ='PAID' where receipt_id = r.id;
		update bill_detail set status = 'PAID' where bill_id = (select id from bill where receipt_id = r.id);
	end if;
  return r;
end;

$$;
 d   DROP FUNCTION public.updatestatusreceipt(r_id numeric, p_status character varying, p_user numeric);
       public       postgres    false    238    5    1            �           0    0 V   FUNCTION updatestatusreceipt(r_id numeric, p_status character varying, p_user numeric)    ACL     �   GRANT ALL ON FUNCTION public.updatestatusreceipt(r_id numeric, p_status character varying, p_user numeric) TO auth_authenticated;
            public       postgres    false    365            >           1255    38789    wash_search(numeric)    FUNCTION     C  CREATE FUNCTION public.wash_search(br_id numeric) RETURNS SETOF public.wash_search
    LANGUAGE sql STABLE
    AS $$

    select co.id , re.id, wb.wash_bag_name, wm.washer_code, w.status,cu.full_name,w.sn  from wash w inner join wash_bag wb on wb.id = w.wash_bag_id
	inner join washing_machine wm on w.washing_machine_id = wm.id
	inner join receipt re on wb.receipt_id = re.id
	inner join customer_order co on re.order_id = co.id
	inner join customer cu on cu.id = co.customer_id
	where w.status in ('PENDING_SERVING','SERVING', 'FINISHED_SERVING') and co.branch_id = br_id

$$;
 1   DROP FUNCTION public.wash_search(br_id numeric);
       public       postgres    false    5    932            �           0    0 #   FUNCTION wash_search(br_id numeric)    ACL     O   GRANT ALL ON FUNCTION public.wash_search(br_id numeric) TO auth_authenticated;
            public       postgres    false    318            �            1259    29426    user_id_seq    SEQUENCE     �   CREATE SEQUENCE auth_public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth_public.user_id_seq;
       auth_public       postgres    false    11    201            �           0    0    user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE auth_public.user_id_seq OWNED BY auth_public."user".id;
            auth_public       postgres    false    202            �           0    0    SEQUENCE user_id_seq    ACL     �   GRANT ALL ON SEQUENCE auth_public.user_id_seq TO auth_authenticated;
GRANT ALL ON SEQUENCE auth_public.user_id_seq TO auth_anonymous;
            auth_public       postgres    false    202                       1259    47157    ENV_VAR    TABLE     w   CREATE TABLE public."ENV_VAR" (
    key character varying,
    value character varying(255),
    id bigint NOT NULL
);
    DROP TABLE public."ENV_VAR";
       public         postgres    false    5                       1259    47155    ENV_VAR_id_seq    SEQUENCE     y   CREATE SEQUENCE public."ENV_VAR_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."ENV_VAR_id_seq";
       public       postgres    false    5    276            �           0    0    ENV_VAR_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."ENV_VAR_id_seq" OWNED BY public."ENV_VAR".id;
            public       postgres    false    275            �            1259    29443 
   branch_seq    SEQUENCE     s   CREATE SEQUENCE public.branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.branch_seq;
       public       postgres    false    5            �            1259    29445    branch    TABLE     7  CREATE TABLE public.branch (
    id numeric(19,0) DEFAULT nextval('public.branch_seq'::regclass) NOT NULL,
    branch_name character varying(2000) NOT NULL,
    store_id numeric(19,0) NOT NULL,
    address character varying(4000),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    branch_avatar integer,
    latidute character varying(4000),
    longtidute character varying(4000)
);
    DROP TABLE public.branch;
       public         postgres    false    207    5            �           0    0    TABLE branch    ACL     n   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    208                       1259    47192    co_id    TABLE     4   CREATE TABLE public.co_id (
    id numeric(19,0)
);
    DROP TABLE public.co_id;
       public         postgres    false    5            �            1259    29452 	   color_seq    SEQUENCE     r   CREATE SEQUENCE public.color_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.color_seq;
       public       postgres    false    5            �            1259    29454    color    TABLE     �  CREATE TABLE public.color (
    id numeric(19,0) DEFAULT nextval('public.color_seq'::regclass) NOT NULL,
    color_name character varying(2000),
    color_group_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.color;
       public         postgres    false    209    5            �           0    0    TABLE color    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.color TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    210            �            1259    29461    color_group_seq    SEQUENCE     x   CREATE SEQUENCE public.color_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.color_group_seq;
       public       postgres    false    5            �            1259    29463    color_group    TABLE     x  CREATE TABLE public.color_group (
    id numeric(19,0) DEFAULT nextval('public.color_group_seq'::regclass) NOT NULL,
    color_group_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.color_group;
       public         postgres    false    211    5            �           0    0    TABLE color_group    ACL     s   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.color_group TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    212                       1259    47166    coun    TABLE     /   CREATE TABLE public.coun (
    count bigint
);
    DROP TABLE public.coun;
       public         postgres    false    5            �            1259    29485    dry_seq    SEQUENCE     p   CREATE SEQUENCE public.dry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.dry_seq;
       public       postgres    false    5            �            1259    29491 	   dryer_seq    SEQUENCE     r   CREATE SEQUENCE public.dryer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.dryer_seq;
       public       postgres    false    5            �            1259    29500 	   label_seq    SEQUENCE     r   CREATE SEQUENCE public.label_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.label_seq;
       public       postgres    false    5            �            1259    29502    label    TABLE     f  CREATE TABLE public.label (
    id numeric(19,0) DEFAULT nextval('public.label_seq'::regclass) NOT NULL,
    label_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.label;
       public         postgres    false    219    5            �           0    0    TABLE label    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.label TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    220            �            1259    29509    material_seq    SEQUENCE     u   CREATE SEQUENCE public.material_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.material_seq;
       public       postgres    false    5            �            1259    29511    material    TABLE     o  CREATE TABLE public.material (
    id numeric(19,0) DEFAULT nextval('public.material_seq'::regclass) NOT NULL,
    material_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.material;
       public         postgres    false    221    5            �           0    0    TABLE material    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.material TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    222                       1259    38943 
   next_co_id    TABLE     9   CREATE TABLE public.next_co_id (
    id numeric(19,0)
);
    DROP TABLE public.next_co_id;
       public         postgres    false    5            �            1259    29527    payment_seq    SEQUENCE     t   CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.payment_seq;
       public       postgres    false    5            �            1259    29529    payment    TABLE     l  CREATE TABLE public.payment (
    id numeric(19,0) DEFAULT nextval('public.payment_seq'::regclass) NOT NULL,
    payment_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.payment;
       public         postgres    false    225    5                        0    0    TABLE payment    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.payment TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    226            �            1259    29536    post    TABLE     t   CREATE TABLE public.post (
    id integer NOT NULL,
    headline text,
    body text,
    header_image_file text
);
    DROP TABLE public.post;
       public         postgres    false    5                       0    0 
   TABLE post    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.post TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    227            �            1259    29542    post_id_seq    SEQUENCE     �   CREATE SEQUENCE public.post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.post_id_seq;
       public       postgres    false    227    5                       0    0    post_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.post_id_seq OWNED BY public.post.id;
            public       postgres    false    228                       0    0    SEQUENCE post_id_seq    ACL     R   GRANT ALL ON SEQUENCE public.post_id_seq TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    228            �            1259    29544    product_seq    SEQUENCE     t   CREATE SEQUENCE public.product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.product_seq;
       public       postgres    false    5            �            1259    29546    product    TABLE     �  CREATE TABLE public.product (
    id numeric(19,0) DEFAULT nextval('public.product_seq'::regclass) NOT NULL,
    product_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    product_image text,
    short_desc character varying(200),
    product_type_id numeric(19,0),
    product_avatar integer
);
    DROP TABLE public.product;
       public         postgres    false    229    5                       0    0    TABLE product    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    230            �            1259    29553    product_type_seq    SEQUENCE     y   CREATE SEQUENCE public.product_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.product_type_seq;
       public       postgres    false    5            �            1259    29555    product_type    TABLE     {  CREATE TABLE public.product_type (
    id numeric(19,0) DEFAULT nextval('public.product_type_seq'::regclass) NOT NULL,
    product_type_name character varying(2000),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now()
);
     DROP TABLE public.product_type;
       public         postgres    false    231    5                       0    0    TABLE product_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    232            �            1259    29562    promotion_seq    SEQUENCE     v   CREATE SEQUENCE public.promotion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.promotion_seq;
       public       postgres    false    5            �            1259    29564 	   promotion    TABLE     �  CREATE TABLE public.promotion (
    id numeric(19,0) DEFAULT nextval('public.promotion_seq'::regclass) NOT NULL,
    promotion_name character varying(2000),
    sale numeric(2,0),
    date_start date,
    date_end date,
    promotion_code character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
    DROP TABLE public.promotion;
       public         postgres    false    233    5                       0    0    TABLE promotion    ACL     q   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    234            �            1259    29571    promotion_branch_seq    SEQUENCE     }   CREATE SEQUENCE public.promotion_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.promotion_branch_seq;
       public       postgres    false    5            �            1259    29573    promotion_branch    TABLE     �  CREATE TABLE public.promotion_branch (
    id numeric(19,0) DEFAULT nextval('public.promotion_branch_seq'::regclass) NOT NULL,
    promotion_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
 $   DROP TABLE public.promotion_branch;
       public         postgres    false    235    5                       0    0    TABLE promotion_branch    ACL     x   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    236            �            1259    29587    receipt_detail_seq    SEQUENCE     {   CREATE SEQUENCE public.receipt_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.receipt_detail_seq;
       public       postgres    false    5                       0    0    SEQUENCE receipt_detail_seq    ACL     G   GRANT ALL ON SEQUENCE public.receipt_detail_seq TO auth_authenticated;
            public       postgres    false    240            �            1259    29589    receipt_wash_bag_seq    SEQUENCE     }   CREATE SEQUENCE public.receipt_wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.receipt_wash_bag_seq;
       public       postgres    false    5                       1259    38963    service_product_seq    SEQUENCE     |   CREATE SEQUENCE public.service_product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.service_product_seq;
       public       postgres    false    5                       1259    38968    service_product    TABLE     B  CREATE TABLE public.service_product (
    id numeric(19,0) DEFAULT nextval('public.service_product_seq'::regclass) NOT NULL,
    service_type_id numeric(19,0),
    product_id numeric(19,0),
    create_date date DEFAULT now(),
    update_date date DEFAULT now(),
    create_by numeric(19,0),
    update_by numeric(19,0)
);
 #   DROP TABLE public.service_product;
       public         postgres    false    273    5            �            1259    29595    service_type_seq    SEQUENCE     y   CREATE SEQUENCE public.service_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.service_type_seq;
       public       postgres    false    5            �            1259    29597    service_type    TABLE     �  CREATE TABLE public.service_type (
    id numeric(19,0) DEFAULT nextval('public.service_type_seq'::regclass) NOT NULL,
    service_type_name character varying(2000),
    service_type_desc character varying(4000),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    service_type_avatar integer
);
     DROP TABLE public.service_type;
       public         postgres    false    242    5            	           0    0    TABLE service_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    243            �            1259    29604    service_type_branch_seq    SEQUENCE     �   CREATE SEQUENCE public.service_type_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.service_type_branch_seq;
       public       postgres    false    5            �            1259    29606    service_type_branch    TABLE     �  CREATE TABLE public.service_type_branch (
    id numeric(19,0) DEFAULT nextval('public.service_type_branch_seq'::regclass),
    service_type_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
 '   DROP TABLE public.service_type_branch;
       public         postgres    false    244    5            
           0    0    TABLE service_type_branch    ACL     {   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    245            �            1259    29610 	   staff_seq    SEQUENCE     r   CREATE SEQUENCE public.staff_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.staff_seq;
       public       postgres    false    5            �            1259    29612    staff    TABLE     �  CREATE TABLE public.staff (
    id numeric(19,0) DEFAULT nextval('public.staff_seq'::regclass) NOT NULL,
    full_name character varying(2000),
    email character varying(4000),
    username character varying(4000),
    password character varying(4000),
    gender boolean,
    address character varying(4000),
    phone character varying(4000),
    status boolean,
    hash_codes character varying(4000),
    lock_status boolean,
    lock_time integer,
    timelock timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    staff_type_id numeric(19,0),
    branch_id numeric(19,0),
    staff_avatar integer
);
    DROP TABLE public.staff;
       public         postgres    false    246    5                       0    0    TABLE staff    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    247            �            1259    29619    staff_type_seq    SEQUENCE     w   CREATE SEQUENCE public.staff_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.staff_type_seq;
       public       postgres    false    5                       0    0    SEQUENCE staff_type_seq    ACL     C   GRANT ALL ON SEQUENCE public.staff_type_seq TO auth_authenticated;
            public       postgres    false    248            �            1259    29621 
   staff_type    TABLE     �  CREATE TABLE public.staff_type (
    id numeric(19,0) DEFAULT nextval('public.staff_type_seq'::regclass) NOT NULL,
    staff_type_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    staff_code character varying(4000)
);
    DROP TABLE public.staff_type;
       public         postgres    false    248    5                       0    0    TABLE staff_type    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    249            �            1259    29628 	   store_seq    SEQUENCE     r   CREATE SEQUENCE public.store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.store_seq;
       public       postgres    false    5            �            1259    29630    store    TABLE     �  CREATE TABLE public.store (
    id numeric(19,0) DEFAULT nextval('public.store_seq'::regclass) NOT NULL,
    store_name character varying(2000),
    address character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    store_avatar integer
);
    DROP TABLE public.store;
       public         postgres    false    250    5                       0    0    TABLE store    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.store TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    251                       1259    30340    task    TABLE     �  CREATE TABLE public.task (
    id integer NOT NULL,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date date DEFAULT now(),
    update_date date DEFAULT now(),
    task_type character varying(4000),
    current_staff numeric(19,0),
    previous_staff numeric(19,0),
    customer_order numeric(19,0),
    receipt numeric(19,0),
    previous_status character varying(4000),
    current_status character varying(4000),
    previous_task character varying(1),
    branch_id numeric(19,0)
);
    DROP TABLE public.task;
       public         postgres    false    5                       0    0 
   TABLE task    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.task TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    267            
           1259    30338    task_id_seq    SEQUENCE     �   CREATE SEQUENCE public.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.task_id_seq;
       public       postgres    false    5    267                       0    0    task_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;
            public       postgres    false    266                       0    0    SEQUENCE task_id_seq    ACL     @   GRANT ALL ON SEQUENCE public.task_id_seq TO auth_authenticated;
            public       postgres    false    266            �            1259    29637    time_schedule_seq    SEQUENCE     z   CREATE SEQUENCE public.time_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.time_schedule_seq;
       public       postgres    false    5                       0    0    SEQUENCE time_schedule_seq    ACL     F   GRANT ALL ON SEQUENCE public.time_schedule_seq TO auth_authenticated;
            public       postgres    false    252            �            1259    29639    time_schedule    TABLE     �  CREATE TABLE public.time_schedule (
    id numeric(19,0) DEFAULT nextval('public.time_schedule_seq'::regclass) NOT NULL,
    time_schedule_no character varying(200),
    time_start time without time zone,
    time_end time without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200)
);
 !   DROP TABLE public.time_schedule;
       public         postgres    false    252    5                       0    0    TABLE time_schedule    ACL     u   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.time_schedule TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    253            �            1259    29643    unit_seq    SEQUENCE     q   CREATE SEQUENCE public.unit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.unit_seq;
       public       postgres    false    5            �            1259    29645    unit    TABLE     }  CREATE TABLE public.unit (
    id numeric(19,0) DEFAULT nextval('public.unit_seq'::regclass) NOT NULL,
    unit_name character varying(200) NOT NULL,
    status character varying(200),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now()
);
    DROP TABLE public.unit;
       public         postgres    false    254    5                       0    0 
   TABLE unit    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    255                       1259    38946    wa    TABLE     1   CREATE TABLE public.wa (
    id numeric(19,0)
);
    DROP TABLE public.wa;
       public         postgres    false    5                       1259    29655    wash_seq    SEQUENCE     q   CREATE SEQUENCE public.wash_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.wash_seq;
       public       postgres    false    5                       0    0    SEQUENCE wash_seq    ACL     =   GRANT ALL ON SEQUENCE public.wash_seq TO auth_authenticated;
            public       postgres    false    258                       1259    29657    wash    TABLE     �  CREATE TABLE public.wash (
    id numeric(19,0) DEFAULT nextval('public.wash_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    washing_machine_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    sn integer
);
    DROP TABLE public.wash;
       public         postgres    false    258    5                       0    0 
   TABLE wash    ACL     6   GRANT ALL ON TABLE public.wash TO auth_authenticated;
            public       postgres    false    259                       1259    29661    wash_bag_seq    SEQUENCE     u   CREATE SEQUENCE public.wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.wash_bag_seq;
       public       postgres    false    5                       0    0    SEQUENCE wash_bag_seq    ACL     A   GRANT ALL ON SEQUENCE public.wash_bag_seq TO auth_authenticated;
            public       postgres    false    260                       1259    29663    wash_bag    TABLE     �  CREATE TABLE public.wash_bag (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_seq'::regclass) NOT NULL,
    wash_bag_name character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone DEFAULT now(),
    status character varying(200),
    receipt_id numeric
);
    DROP TABLE public.wash_bag;
       public         postgres    false    260    5                       0    0    TABLE wash_bag    ACL     �   GRANT DELETE ON TABLE public.wash_bag TO auth_authenticated;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    261                       1259    47197    washer_list    TABLE     �   CREATE TABLE public.washer_list (
    id numeric(19,0),
    sum bigint,
    code character varying(4000),
    serving numeric(19,0)[],
    pending numeric(19,0)[]
);
    DROP TABLE public.washer_list;
       public         postgres    false    5                       2604    29679    user id    DEFAULT     n   ALTER TABLE ONLY auth_public."user" ALTER COLUMN id SET DEFAULT nextval('auth_public.user_id_seq'::regclass);
 =   ALTER TABLE auth_public."user" ALTER COLUMN id DROP DEFAULT;
       auth_public       postgres    false    202    201            n           2604    47160 
   ENV_VAR id    DEFAULT     l   ALTER TABLE ONLY public."ENV_VAR" ALTER COLUMN id SET DEFAULT nextval('public."ENV_VAR_id_seq"'::regclass);
 ;   ALTER TABLE public."ENV_VAR" ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    275    276    276            1           2604    29680    post id    DEFAULT     b   ALTER TABLE ONLY public.post ALTER COLUMN id SET DEFAULT nextval('public.post_id_seq'::regclass);
 6   ALTER TABLE public.post ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    228    227            h           2604    30343    task id    DEFAULT     b   ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);
 6   ALTER TABLE public.task ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    266    267    267            {          0    29412    user 
   TABLE DATA               W   COPY auth_public."user" (id, first_name, last_name, created_at, user_type) FROM stdin;
    auth_public       postgres    false    201   U      �          0    47157    ENV_VAR 
   TABLE DATA               3   COPY public."ENV_VAR" (key, value, id) FROM stdin;
    public       postgres    false    276   �V      ~          0    29430    bill 
   TABLE DATA               �   COPY public.bill (id, receipt_id, create_id, shipper_id, payment_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    204   3W      �          0    29436    bill_detail 
   TABLE DATA               �   COPY public.bill_detail (id, bill_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status, unit_price, received_amount) FROM stdin;
    public       postgres    false    206   �W      �          0    29445    branch 
   TABLE DATA               �   COPY public.branch (id, branch_name, store_id, address, create_by, update_by, create_date, update_date, status, branch_avatar, latidute, longtidute) FROM stdin;
    public       postgres    false    208   X      �          0    47192    co_id 
   TABLE DATA               #   COPY public.co_id (id) FROM stdin;
    public       postgres    false    278   �Y      �          0    29454    color 
   TABLE DATA               w   COPY public.color (id, color_name, color_group_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    210   �Y      �          0    29463    color_group 
   TABLE DATA               s   COPY public.color_group (id, color_group_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    212   pZ      �          0    47166    coun 
   TABLE DATA               %   COPY public.coun (count) FROM stdin;
    public       postgres    false    277   �Z      �          0    29472    customer 
   TABLE DATA               �   COPY public.customer (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, customer_avatar) FROM stdin;
    public       postgres    false    214   �Z      �          0    29481    customer_order 
   TABLE DATA               �   COPY public.customer_order (id, customer_id, branch_id, pick_up_date, pick_up_time_id, delivery_date, delivery_time_id, create_by, update_by, create_date, update_date, status, pick_up_place, delivery_place, promotion_id, confirm_by_customer) FROM stdin;
    public       postgres    false    216   _      �          0    29502    label 
   TABLE DATA               g   COPY public.label (id, label_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    220   )`      �          0    29511    material 
   TABLE DATA               m   COPY public.material (id, material_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    222   �`      �          0    38943 
   next_co_id 
   TABLE DATA               (   COPY public.next_co_id (id) FROM stdin;
    public       postgres    false    271   �a      �          0    29520    order_detail 
   TABLE DATA               �   COPY public.order_detail (id, order_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status, unit_price, weight) FROM stdin;
    public       postgres    false    224   �a      �          0    29529    payment 
   TABLE DATA               k   COPY public.payment (id, payment_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    226   c      �          0    29536    post 
   TABLE DATA               E   COPY public.post (id, headline, body, header_image_file) FROM stdin;
    public       postgres    false    227   :c      �          0    29546    product 
   TABLE DATA               �   COPY public.product (id, product_name, create_by, update_by, create_date, update_date, status, product_image, short_desc, product_type_id, product_avatar) FROM stdin;
    public       postgres    false    230   �f      �          0    29555    product_type 
   TABLE DATA               u   COPY public.product_type (id, product_type_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    232   �g      �          0    29564 	   promotion 
   TABLE DATA               �   COPY public.promotion (id, promotion_name, sale, date_start, date_end, promotion_code, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    234   Ph      �          0    29573    promotion_branch 
   TABLE DATA                  COPY public.promotion_branch (id, promotion_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    236   �h      �          0    29579    receipt 
   TABLE DATA               �   COPY public.receipt (id, order_id, pick_up_time, delivery_time, create_by, update_by, create_date, update_date, status, pick_up_date, delivery_date, pick_up_place, delivery_place, staff_pick_up, staff_delivery, delivery_amount) FROM stdin;
    public       postgres    false    238   fi      �          0    29583    receipt_detail 
   TABLE DATA               �   COPY public.receipt_detail (id, receipt_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status, recieved_amount, unit_price, delivery_amount) FROM stdin;
    public       postgres    false    239   0j      �          0    38968    service_product 
   TABLE DATA               z   COPY public.service_product (id, service_type_id, product_id, create_date, update_date, create_by, update_by) FROM stdin;
    public       postgres    false    274   Fk      �          0    29597    service_type 
   TABLE DATA               �   COPY public.service_type (id, service_type_name, service_type_desc, status, create_by, update_by, create_date, update_date, service_type_avatar) FROM stdin;
    public       postgres    false    243   ck      �          0    29606    service_type_branch 
   TABLE DATA               �   COPY public.service_type_branch (id, service_type_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    245   |n      �          0    29612    staff 
   TABLE DATA               �   COPY public.staff (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, staff_type_id, branch_id, staff_avatar) FROM stdin;
    public       postgres    false    247   'o      �          0    29621 
   staff_type 
   TABLE DATA               }   COPY public.staff_type (id, staff_type_name, create_by, update_by, create_date, update_date, status, staff_code) FROM stdin;
    public       postgres    false    249   �q      �          0    29630    store 
   TABLE DATA               ~   COPY public.store (id, store_name, address, create_by, update_by, create_date, update_date, status, store_avatar) FROM stdin;
    public       postgres    false    251   zr      �          0    30340    task 
   TABLE DATA               �   COPY public.task (id, create_by, update_by, create_date, update_date, task_type, current_staff, previous_staff, customer_order, receipt, previous_status, current_status, previous_task, branch_id) FROM stdin;
    public       postgres    false    267   �r      �          0    29639    time_schedule 
   TABLE DATA               �   COPY public.time_schedule (id, time_schedule_no, time_start, time_end, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    253   �t      �          0    29645    unit 
   TABLE DATA               e   COPY public.unit (id, unit_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    255   �u      �          0    29651 
   unit_price 
   TABLE DATA               �   COPY public.unit_price (id, product_id, service_type_id, material_id, unit_id, apply_date, price, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    257   �u      �          0    38946    wa 
   TABLE DATA                   COPY public.wa (id) FROM stdin;
    public       postgres    false    272   8      �          0    29657    wash 
   TABLE DATA                  COPY public.wash (id, wash_bag_id, washing_machine_id, create_by, update_by, create_date, update_date, status, sn) FROM stdin;
    public       postgres    false    259   ]      �          0    29663    wash_bag 
   TABLE DATA               y   COPY public.wash_bag (id, wash_bag_name, create_by, update_by, create_date, update_date, status, receipt_id) FROM stdin;
    public       postgres    false    261   �      �          0    29669    wash_bag_detail 
   TABLE DATA               �   COPY public.wash_bag_detail (id, wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    263   ��      �          0    47197    washer_list 
   TABLE DATA               F   COPY public.washer_list (id, sum, code, serving, pending) FROM stdin;
    public       postgres    false    279   c�      �          0    29675    washing_machine 
   TABLE DATA               �   COPY public.washing_machine (id, branch_id, bought_date, create_by, update_by, create_date, update_date, status, capacity, washer_code) FROM stdin;
    public       postgres    false    265   ��                 0    0    user_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth_public.user_id_seq', 36, true);
            auth_public       postgres    false    202                       0    0    ENV_VAR_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."ENV_VAR_id_seq"', 1, false);
            public       postgres    false    275                       0    0    bill_detail_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.bill_detail_seq', 15, true);
            public       postgres    false    205                       0    0    bill_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.bill_seq', 14, true);
            public       postgres    false    203                       0    0 
   branch_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.branch_seq', 6, true);
            public       postgres    false    207                       0    0    color_group_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.color_group_seq', 2, true);
            public       postgres    false    211                       0    0 	   color_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.color_seq', 7, true);
            public       postgres    false    209                        0    0    customer_order_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.customer_order_seq', 89, true);
            public       postgres    false    215            !           0    0    customer_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.customer_seq', 3, true);
            public       postgres    false    213            "           0    0    dry_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.dry_seq', 1, false);
            public       postgres    false    217            #           0    0 	   dryer_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.dryer_seq', 1, false);
            public       postgres    false    218            $           0    0 	   label_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.label_seq', 9, true);
            public       postgres    false    219            %           0    0    material_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.material_seq', 10, true);
            public       postgres    false    221            &           0    0    order_detail_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.order_detail_seq', 147, true);
            public       postgres    false    223            '           0    0    payment_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.payment_seq', 1, false);
            public       postgres    false    225            (           0    0    post_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.post_id_seq', 30, true);
            public       postgres    false    228            )           0    0    product_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.product_seq', 6, true);
            public       postgres    false    229            *           0    0    product_type_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.product_type_seq', 6, true);
            public       postgres    false    231            +           0    0    promotion_branch_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.promotion_branch_seq', 9, true);
            public       postgres    false    235            ,           0    0    promotion_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.promotion_seq', 5, true);
            public       postgres    false    233            -           0    0    receipt_detail_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.receipt_detail_seq', 109, true);
            public       postgres    false    240            .           0    0    receipt_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.receipt_seq', 70, true);
            public       postgres    false    237            /           0    0    receipt_wash_bag_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.receipt_wash_bag_seq', 1, false);
            public       postgres    false    241            0           0    0    service_product_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.service_product_seq', 1, false);
            public       postgres    false    273            1           0    0    service_type_branch_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.service_type_branch_seq', 33, true);
            public       postgres    false    244            2           0    0    service_type_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.service_type_seq', 13, true);
            public       postgres    false    242            3           0    0 	   staff_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.staff_seq', 1, false);
            public       postgres    false    246            4           0    0    staff_type_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.staff_type_seq', 3, true);
            public       postgres    false    248            5           0    0 	   store_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.store_seq', 1, true);
            public       postgres    false    250            6           0    0    task_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.task_id_seq', 328, true);
            public       postgres    false    266            7           0    0    time_schedule_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.time_schedule_seq', 2, true);
            public       postgres    false    252            8           0    0    unit_price_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.unit_price_seq', 710, true);
            public       postgres    false    256            9           0    0    unit_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.unit_seq', 4, true);
            public       postgres    false    254            :           0    0    wash_bag_detail_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.wash_bag_detail_seq', 80, true);
            public       postgres    false    262            ;           0    0    wash_bag_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.wash_bag_seq', 73, true);
            public       postgres    false    260            <           0    0    wash_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.wash_seq', 271, true);
            public       postgres    false    258            =           0    0    washing_machine_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.washing_machine_seq', 24, true);
            public       postgres    false    264            p           2606    29682    user user_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY auth_public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 ?   ALTER TABLE ONLY auth_public."user" DROP CONSTRAINT user_pkey;
       auth_public         postgres    false    201            �           2606    47165    ENV_VAR ENV_VAR_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public."ENV_VAR"
    ADD CONSTRAINT "ENV_VAR_pkey" PRIMARY KEY (id);
 B   ALTER TABLE ONLY public."ENV_VAR" DROP CONSTRAINT "ENV_VAR_pkey";
       public         postgres    false    276            t           2606    29684    bill_detail bill_detail_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT bill_detail_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT bill_detail_pkey;
       public         postgres    false    206            r           2606    29686    bill bill_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.bill DROP CONSTRAINT bill_pkey;
       public         postgres    false    204            v           2606    29688    branch branch_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_pkey;
       public         postgres    false    208            z           2606    29690    color_group color_group_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.color_group
    ADD CONSTRAINT color_group_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.color_group DROP CONSTRAINT color_group_pkey;
       public         postgres    false    212            x           2606    29692    color color_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.color DROP CONSTRAINT color_pkey;
       public         postgres    false    210            ~           2606    29694 "   customer_order customer_order_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT customer_order_pkey;
       public         postgres    false    216            |           2606    29696    customer customer_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_pkey;
       public         postgres    false    214            �           2606    29702    label label_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.label DROP CONSTRAINT label_pkey;
       public         postgres    false    220            �           2606    29704    material material_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.material DROP CONSTRAINT material_pkey;
       public         postgres    false    222            �           2606    29706    order_detail order_detail_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT order_detail_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT order_detail_pkey;
       public         postgres    false    224            �           2606    29708    payment payment_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.payment DROP CONSTRAINT payment_pkey;
       public         postgres    false    226            �           2606    29710    post post_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.post DROP CONSTRAINT post_pkey;
       public         postgres    false    227            �           2606    29712    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public         postgres    false    230            �           2606    29714    product_type product_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_type DROP CONSTRAINT product_type_pkey;
       public         postgres    false    232            �           2606    29716 &   promotion_branch promotion_branch_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT promotion_branch_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT promotion_branch_pkey;
       public         postgres    false    236            �           2606    29718    promotion promotion_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public         postgres    false    234            �           2606    29720 "   receipt_detail receipt_detail_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT receipt_detail_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT receipt_detail_pkey;
       public         postgres    false    239            �           2606    29722    receipt receipt_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.receipt DROP CONSTRAINT receipt_pkey;
       public         postgres    false    238            �           2606    38975 $   service_product service_product_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.service_product
    ADD CONSTRAINT service_product_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.service_product DROP CONSTRAINT service_product_pkey;
       public         postgres    false    274            �           2606    29726    service_type service_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_pkey;
       public         postgres    false    243            �           2606    29728    staff staff_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public         postgres    false    247            �           2606    29730    staff_type staff_type_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.staff_type
    ADD CONSTRAINT staff_type_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.staff_type DROP CONSTRAINT staff_type_pkey;
       public         postgres    false    249            �           2606    29732    store store_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.store DROP CONSTRAINT store_pkey;
       public         postgres    false    251            �           2606    29734     time_schedule time_schedule_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.time_schedule
    ADD CONSTRAINT time_schedule_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.time_schedule DROP CONSTRAINT time_schedule_pkey;
       public         postgres    false    253            �           2606    29736    unit unit_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.unit DROP CONSTRAINT unit_pkey;
       public         postgres    false    255            �           2606    29738    unit_price unit_price_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT unit_price_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT unit_price_pkey;
       public         postgres    false    257            �           2606    29740 $   wash_bag_detail wash_bag_detail_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT wash_bag_detail_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT wash_bag_detail_pkey;
       public         postgres    false    263            �           2606    29742    wash_bag wash_bag_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.wash_bag
    ADD CONSTRAINT wash_bag_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.wash_bag DROP CONSTRAINT wash_bag_pkey;
       public         postgres    false    261            �           2606    29744    wash wash_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT wash_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.wash DROP CONSTRAINT wash_pkey;
       public         postgres    false    259            �           2606    29746 $   washing_machine washing_machine_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.washing_machine
    ADD CONSTRAINT washing_machine_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.washing_machine DROP CONSTRAINT washing_machine_pkey;
       public         postgres    false    265            �           2606    29747     branch branch_branch_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_avatar_fkey FOREIGN KEY (branch_avatar) REFERENCES public.post(id);
 J   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_branch_avatar_fkey;
       public       postgres    false    208    227    3208            �           2606    29752 &   customer customer_customer_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_customer_avatar_fkey FOREIGN KEY (customer_avatar) REFERENCES public.post(id);
 P   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_customer_avatar_fkey;
       public       postgres    false    214    227    3208            �           2606    38923    bill fk_bill_create_by    FK CONSTRAINT     w   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_create_by FOREIGN KEY (create_by) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_create_by;
       public       postgres    false    3224    204    247            �           2606    29757    bill fk_bill_create_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_create_id FOREIGN KEY (create_id) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_create_id;
       public       postgres    false    247    204    3224            �           2606    29762 "   bill_detail fk_bill_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_bill_id FOREIGN KEY (bill_id) REFERENCES public.bill(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_bill_id;
       public       postgres    false    206    3186    204            �           2606    29767 #   bill_detail fk_bill_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_color_id;
       public       postgres    false    210    206    3192            �           2606    29772 #   bill_detail fk_bill_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_label_id;
       public       postgres    false    206    220    3200            �           2606    29777 &   bill_detail fk_bill_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 P   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_material_id;
       public       postgres    false    222    206    3202            �           2606    29782 %   bill_detail fk_bill_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 O   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_product_id;
       public       postgres    false    230    206    3210            �           2606    29787 *   bill_detail fk_bill_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 T   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_service_type_id;
       public       postgres    false    206    243    3222            �           2606    29792 "   bill_detail fk_bill_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_id;
       public       postgres    false    206    3232    255            �           2606    38911 %   bill_detail fk_bill_detail_unit_price    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_price FOREIGN KEY (unit_price) REFERENCES public.unit_price(id);
 O   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_price;
       public       postgres    false    3234    257    206            �           2606    29797    bill fk_bill_payment_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_payment_id FOREIGN KEY (payment_id) REFERENCES public.payment(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_payment_id;
       public       postgres    false    204    3206    226            �           2606    29802    bill fk_bill_receipt_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_receipt_id;
       public       postgres    false    3218    238    204            �           2606    29807    bill fk_bill_shipper_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_shipper_id FOREIGN KEY (shipper_id) REFERENCES public.staff(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_shipper_id;
       public       postgres    false    204    3224    247            �           2606    38928    bill fk_bill_update_by    FK CONSTRAINT     w   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_update_by FOREIGN KEY (update_by) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_update_by;
       public       postgres    false    247    3224    204            �           2606    29812    staff fk_branch_id    FK CONSTRAINT     t   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 <   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_branch_id;
       public       postgres    false    208    247    3190            �           2606    29817    branch fk_branch_store_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT fk_branch_store_id FOREIGN KEY (store_id) REFERENCES public.store(id);
 C   ALTER TABLE ONLY public.branch DROP CONSTRAINT fk_branch_store_id;
       public       postgres    false    208    3228    251            �           2606    29822    color fk_color_color_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.color
    ADD CONSTRAINT fk_color_color_group_id FOREIGN KEY (color_group_id) REFERENCES public.color_group(id);
 G   ALTER TABLE ONLY public.color DROP CONSTRAINT fk_color_color_group_id;
       public       postgres    false    210    212    3194            �           2606    30349    task fk_create_by    FK CONSTRAINT     r   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_create_by FOREIGN KEY (create_by) REFERENCES public.staff(id);
 ;   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_create_by;
       public       postgres    false    3224    267    247            �           2606    30359    task fk_current_staff    FK CONSTRAINT     z   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_current_staff FOREIGN KEY (current_staff) REFERENCES public.staff(id);
 ?   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_current_staff;
       public       postgres    false    267    3224    247            �           2606    30369    task fk_customer_order    FK CONSTRAINT     �   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_customer_order FOREIGN KEY (customer_order) REFERENCES public.customer_order(id);
 @   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_customer_order;
       public       postgres    false    216    267    3198            �           2606    29827 *   customer_order fk_customer_order_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 T   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_branch_id;
       public       postgres    false    216    208    3190            �           2606    29832 ,   customer_order fk_customer_order_customer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 V   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_customer_id;
       public       postgres    false    3196    214    216            �           2606    29837 1   customer_order fk_customer_order_delivery_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_delivery_time_id FOREIGN KEY (delivery_time_id) REFERENCES public.time_schedule(id);
 [   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_delivery_time_id;
       public       postgres    false    216    3230    253            �           2606    29842 0   customer_order fk_customer_order_pick_up_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_pick_up_time_id FOREIGN KEY (pick_up_time_id) REFERENCES public.time_schedule(id);
 Z   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_pick_up_time_id;
       public       postgres    false    253    216    3230            �           2606    30204 -   customer_order fk_customer_order_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 W   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_promotion_id;
       public       postgres    false    216    234    3214            �           2606    30234 %   order_detail fk_order_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_color_id;
       public       postgres    false    224    210    3192            �           2606    29862 %   order_detail fk_order_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_label_id;
       public       postgres    false    224    220    3200            �           2606    30224 (   order_detail fk_order_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 R   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_material_id;
       public       postgres    false    224    222    3202            �           2606    29867 %   order_detail fk_order_detail_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_order_id;
       public       postgres    false    216    3198    224            �           2606    30214 '   order_detail fk_order_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 Q   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_product_id;
       public       postgres    false    224    230    3210            �           2606    29872 ,   order_detail fk_order_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 V   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_service_type_id;
       public       postgres    false    224    3222    243            �           2606    29877 $   order_detail fk_order_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 N   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_id;
       public       postgres    false    3232    224    255            �           2606    30261 '   order_detail fk_order_detail_unit_price    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_price FOREIGN KEY (unit_price) REFERENCES public.unit_price(id);
 Q   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_price;
       public       postgres    false    257    224    3234            �           2606    30364    task fk_previous_staff    FK CONSTRAINT     |   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_previous_staff FOREIGN KEY (previous_staff) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_previous_staff;
       public       postgres    false    247    267    3224            �           2606    29882 "   product fk_product_product_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT fk_product_product_type_id FOREIGN KEY (product_type_id) REFERENCES public.product_type(id);
 L   ALTER TABLE ONLY public.product DROP CONSTRAINT fk_product_product_type_id;
       public       postgres    false    230    232    3212            �           2606    29887 .   promotion_branch fk_promotion_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 X   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_branch_id;
       public       postgres    false    236    208    3190            �           2606    29892 1   promotion_branch fk_promotion_branch_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 [   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_promotion_id;
       public       postgres    false    236    3214    234            �           2606    30374    task fk_receipt    FK CONSTRAINT     p   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_receipt FOREIGN KEY (receipt) REFERENCES public.receipt(id);
 9   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_receipt;
       public       postgres    false    267    238    3218            �           2606    29897 (   receipt_detail fk_receipt_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_bill_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_bill_id;
       public       postgres    false    238    239    3218            �           2606    29902 )   receipt_detail fk_receipt_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_color_id;
       public       postgres    false    239    210    3192            �           2606    29907 )   receipt_detail fk_receipt_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_label_id;
       public       postgres    false    220    3200    239            �           2606    29912 ,   receipt_detail fk_receipt_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 V   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_material_id;
       public       postgres    false    239    3202    222            �           2606    29917 +   receipt_detail fk_receipt_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 U   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_product_id;
       public       postgres    false    3210    230    239            �           2606    29922 0   receipt_detail fk_receipt_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 Z   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_service_type_id;
       public       postgres    false    239    3222    243            �           2606    29927 (   receipt_detail fk_receipt_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_id;
       public       postgres    false    255    3232    239            �           2606    30266 +   receipt_detail fk_receipt_detail_unit_price    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_price FOREIGN KEY (unit_price) REFERENCES public.unit_price(id);
 U   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_price;
       public       postgres    false    239    3234    257            �           2606    29932    receipt fk_receipt_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 E   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_order_id;
       public       postgres    false    238    216    3198            �           2606    30328 !   receipt fk_receipt_staff_delivery    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_staff_delivery FOREIGN KEY (staff_delivery) REFERENCES public.staff(id);
 K   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_staff_delivery;
       public       postgres    false    238    3224    247            �           2606    30323     receipt fk_receipt_staff_pick_up    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_staff_pick_up FOREIGN KEY (staff_pick_up) REFERENCES public.staff(id);
 J   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_staff_pick_up;
       public       postgres    false    238    247    3224            �           2606    38986 ,   service_product fk_service_product_create_by    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_product
    ADD CONSTRAINT fk_service_product_create_by FOREIGN KEY (create_by) REFERENCES public.staff(id);
 V   ALTER TABLE ONLY public.service_product DROP CONSTRAINT fk_service_product_create_by;
       public       postgres    false    274    3224    247            �           2606    38981 -   service_product fk_service_product_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_product
    ADD CONSTRAINT fk_service_product_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.service_product DROP CONSTRAINT fk_service_product_product_id;
       public       postgres    false    3210    230    274            �           2606    38976 2   service_product fk_service_product_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_product
    ADD CONSTRAINT fk_service_product_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 \   ALTER TABLE ONLY public.service_product DROP CONSTRAINT fk_service_product_service_type_id;
       public       postgres    false    3222    243    274            �           2606    38991 ,   service_product fk_service_product_update_by    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_product
    ADD CONSTRAINT fk_service_product_update_by FOREIGN KEY (update_by) REFERENCES public.staff(id);
 V   ALTER TABLE ONLY public.service_product DROP CONSTRAINT fk_service_product_update_by;
       public       postgres    false    274    3224    247            �           2606    30048 #   service_type fk_service_type_avatar    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT fk_service_type_avatar FOREIGN KEY (service_type_avatar) REFERENCES public.post(id);
 M   ALTER TABLE ONLY public.service_type DROP CONSTRAINT fk_service_type_avatar;
       public       postgres    false    243    227    3208            �           2606    29947 4   service_type_branch fk_service_type_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 ^   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_branch_id;
       public       postgres    false    208    3190    245            �           2606    29952 :   service_type_branch fk_service_type_branch_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 d   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_service_type_id;
       public       postgres    false    245    3222    243            �           2606    29957    staff fk_staff_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_type_id FOREIGN KEY (staff_type_id) REFERENCES public.staff_type(id);
 @   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_staff_type_id;
       public       postgres    false    3226    249    247            �           2606    29962 #   unit_price fk_unit_price_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 M   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_product_id;
       public       postgres    false    230    3210    257            �           2606    29967 (   unit_price fk_unit_price_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 R   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_service_type_id;
       public       postgres    false    3222    243    257            �           2606    29972     unit_price fk_unit_price_unit_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 J   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_unit_id;
       public       postgres    false    255    257    3232            �           2606    30354    task fk_update_by    FK CONSTRAINT     r   ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_update_by FOREIGN KEY (update_by) REFERENCES public.staff(id);
 ;   ALTER TABLE ONLY public.task DROP CONSTRAINT fk_update_by;
       public       postgres    false    3224    247    267            �           2606    29977 *   wash_bag_detail fk_wash_bag_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_bill_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_bill_id;
       public       postgres    false    3238    263    261            �           2606    29982 +   wash_bag_detail fk_wash_bag_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_color_id;
       public       postgres    false    3192    210    263            �           2606    29987 +   wash_bag_detail fk_wash_bag_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_label_id;
       public       postgres    false    263    220    3200            �           2606    29992 .   wash_bag_detail fk_wash_bag_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 X   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_material_id;
       public       postgres    false    263    3202    222            �           2606    29997 -   wash_bag_detail fk_wash_bag_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_product_id;
       public       postgres    false    230    263    3210            �           2606    30002 2   wash_bag_detail fk_wash_bag_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 \   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_service_type_id;
       public       postgres    false    263    243    3222            �           2606    30007 *   wash_bag_detail fk_wash_bag_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_unit_id;
       public       postgres    false    3232    263    255            �           2606    38749    wash_bag fk_wash_bag_receipt_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag
    ADD CONSTRAINT fk_wash_bag_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 I   ALTER TABLE ONLY public.wash_bag DROP CONSTRAINT fk_wash_bag_receipt_id;
       public       postgres    false    261    3218    238            �           2606    30012    wash fk_wash_wash_bag_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 B   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_bag_id;
       public       postgres    false    259    3238    261            �           2606    30017 $   wash fk_wash_wash_washing_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_washing_machine_id FOREIGN KEY (washing_machine_id) REFERENCES public.washing_machine(id);
 N   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_washing_machine_id;
       public       postgres    false    3242    265    259            �           2606    30022 #   product product_product_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_product_avatar_fkey FOREIGN KEY (product_avatar) REFERENCES public.post(id);
 M   ALTER TABLE ONLY public.product DROP CONSTRAINT product_product_avatar_fkey;
       public       postgres    false    3208    230    227            �           2606    30027 2   service_type service_type_service_type_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_service_type_avatar_fkey FOREIGN KEY (service_type_avatar) REFERENCES public.post(id);
 \   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_service_type_avatar_fkey;
       public       postgres    false    243    227    3208            �           2606    30032    staff staff_staff_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_staff_avatar_fkey FOREIGN KEY (staff_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_staff_avatar_fkey;
       public       postgres    false    247    227    3208            �           2606    30037    store store_store_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_store_avatar_fkey FOREIGN KEY (store_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.store DROP CONSTRAINT store_store_avatar_fkey;
       public       postgres    false    251    227    3208            �           2606    30425    task task_branch_id    FK CONSTRAINT     u   ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 =   ALTER TABLE ONLY public.task DROP CONSTRAINT task_branch_id;
       public       postgres    false    3190    208    267            
           3466    47190    postgraphile_watch_ddl    EVENT TRIGGER       CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_ddl();
 +   DROP EVENT TRIGGER postgraphile_watch_ddl;
             postgres    false    289                       3466    47191    postgraphile_watch_drop    EVENT TRIGGER     y   CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_drop();
 ,   DROP EVENT TRIGGER postgraphile_watch_drop;
             postgres    false    360            w           3256    30044    user delete_user    POLICY        CREATE POLICY delete_user ON auth_public."user" FOR DELETE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY delete_user ON auth_public."user";
       auth_public       postgres    false    201    284    201            z           3256    38633    user insert_user    POLICY     A  CREATE POLICY insert_user ON auth_public."user" FOR INSERT TO auth_authenticated WITH CHECK ((((id)::numeric IN ( SELECT st.id
   FROM (public.staff_type stp
     LEFT JOIN public.staff st ON ((stp.id = st.staff_type_id)))
  WHERE ((stp.staff_code)::text = 'STAFF_01'::text))) AND (id = auth_public.current_user_id())));
 /   DROP POLICY insert_user ON auth_public."user";
       auth_public       postgres    false    201    249    249    201    247    284    247            x           3256    30045    user select_user    POLICY     I   CREATE POLICY select_user ON auth_public."user" FOR SELECT USING (true);
 /   DROP POLICY select_user ON auth_public."user";
       auth_public       postgres    false    201            y           3256    30046    user update_user    POLICY        CREATE POLICY update_user ON auth_public."user" FOR UPDATE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY update_user ON auth_public."user";
       auth_public       postgres    false    201    284    201            v           0    29412    user    ROW SECURITY     9   ALTER TABLE auth_public."user" ENABLE ROW LEVEL SECURITY;            auth_public       postgres    false            {   �  x����j1��z�fF_7�c��S{B�	Y�!��^Jo=�Z���D�1A+㤇=��F��!q���^�������`4�1�1�4&F�*����׶Y�߭/�O���u{__�y��H�H!T�1 ��D�#��`�!ѬU�*�8=�4;�,��_��r>�n$������HVYKa(��2D���6n ��H �l=�\��������@<��e������^ܭ�E&Q���[;�E���ry�TMSUb�Tu����C��;N,�m1V�������_��Rw��c@��w������}Z�r��夐i rPLA;[R�ӽ-�]̊4"mѐ���ژ�"V��?���P��"`7�|�!qz69:zG�^!�N������Mk�\~� ����N���r�ʦbM��ή�M�:�ꬳ[)�����͗I��R��u���r{œ� �Pr��1�P����!6�      �   4   x���u�q
�4�4�
q]�\8�9� �� g��`NSNc�=... H��      ~   M   x�34�43��"S 420��54�5�P04�24�22�31037�D�22�21�25�3443���pqqu����� ��      �   g   x�����0k�^@���W,u��p�t���Se ���$p4�� j���u����=���F,C������KuXn�l��s>߯	�

��_��E�a��E���"P      �   r  x����j�0�g�)� �Н$���C�	�x(��:P��[3u�ti(4K����{�MzNm1��C��w:���%Q?�XSǣ�N�6�/WfKKG�BAD�!������A����l�q�	m�?����Zj�C��6��t�&���bU����,�+-w�io��.�r{G �ǶF�o<6˫��%�u�t�&�JJau����-����FZ��QN$Nie���@u�ʈ��������S~J	(�򵱪Kj�P.�*A� ���?kh~�*劉V2b�m�~g����8���4P���߸%pʙ ���܈F��׈º�w�zz��3{=�"T�#H�U��b��Gh�}Cs�ι뺟��p      �      x������ � �      �   �   x�}�?
�0�99�h��%_�m".N���A��b�[�xqw;֋�&R��%��=~<������u�.X��\� ��
��&�c;_lV�%�(ϻ��A$
��M���tޯ搷`�Bol:�����6E�Α��,����9H$��$MM�M�hs�)�%$�hG�g=� 'Q���s���g�      �   U   x�3��=��T���¼t�?220��54�54U02�21�25ѳ46654�&&�d��rA��<�=1�>K=KCC$}1z\\\ �7      �      x�3������ S �      �     x����r�H���.�����4FM Z�p4�.�ۜ�L�nֳ���Ǽɠ�3��Ϥh,��~_t���͟���6�����~��pS`�X��͋ Ls��6
�L��!s���P���V������U/Mݒ�<���b,��H�Έ�ښ0�����~ex��D���s/�z�[���0j� � ��8����*I��47S����P��|V���n�	����sU��3�xE8�L>|�9��Q�-$� e�Fע�a����C�����t�䱛�P����M^X?[��[��"T(��p�Y�.Z�t�{c�����t�*T��Z��s��}���K"A�����瘧*bĊT��JR��U��EV��t�:]x������z�֖	��?����Wt0Q�g�{[����˝J���vM ��Ԃ��$!t-:΀�g�>L���6�o7�u����T�t!����t���pY��,{&�m�*��F�W��.�v�ڱ?��>��\S�� ��x�\���\@f��M��EN4m���~l�u2-��R���9�Ma4���X�J��}^@@-(��G�[�]t�����E� ���AP�;�����Z����P�Tfeeh���a�眽�xQs�Y��XR�]�j�:���]co����þ]��>/�f���������v,%��
a�v���W�g a����J�,& H�Zt@t.C�>)��a8Oz�F�d-�kA_�q�N������&g�ŝ�nu2����Tf�e	�H�EG�~�{ʓ4��0�`9Z�Y:܋������/�f:�܎��X�v
�B��mN�������~J�Y�b�u�E"�Zt����4�N���z\�0�γ�J�\=䁹��������{�S�~eP��e��UT
�z�⯰�Tgpl� B���Nζ����cǒ-Ge������[�Ɂ-�!��rR����27�rw�0�%��1~ݖy���]�F$M Z'JbP|!��&H�g��h�5�]�      �   �   x����j�0���S�Z#ɒ���f[(����Ca�0H/��?�4';���F�/�>�����`�"n1;�rR����aXI-"L�(�{�}?<�������2��x�ƍ���׏�����u����RMn�.֍�q[O� A�HQtE5���i^Y��Z���^�R�E�(q!�Q�Rq������ge~�ϟ��[c��c�c[1��(��A��� �aN$K�_'��Mנ=��i>)��Z      �   �   x�u�Kj�@��|�^ B����	&���dcH]%�/������/�e>M�pY@�Ӂ���$Z�
3R�}���m>O�@�~_��}��p	]�Sj���v��_H!B�*&���m]�S m�N���%l�f)iC��\��g$���Ҿᳮ�'4a6�����<��u�z����e8��c�Lt��BC.8�/\b�      �   �   x�uбj�@�Y~
�@�I���y+�C��)d�����w�s��A�f��Mb�zB���E��i���]�e{|;�V��zN�Qڐ�P�Y�1:BVc}��hb<��WW$5�$oH�}wJBcД�U���/	Ps�I����b��q��BF$h����B��s�Fd8�?�C=]~�K�<fU��ȭ�},�(�Rd���z �s      �      x������ � �      �     x����N�0���S�Ŏ�89�@/b�I�rA<?n:t�6��Œ�����`�E�~��?�`����Cܡ�1V_�d��%���VM"p7N��aؿ���q��ǩC��Ů�$�o͒J���s�jK�T�T�!�p�s��X��$ 
G��a�;���5��e�-�v%?���YI�����2�z��`�ۯ~�<�~�I��T�V�����M)�9��2����J`�΃�k�"W,>(��_�(Ac�'=;���A���qsPK����M��      �      x������ � �      �   �  x�՗MoG�����޸��j�`��^z`p��u�݅v�E��K�v�2� ���t�|8|I����a���uw(�vG}�������q�֥M�r�i_����=����ތ�6�V6]6tG�N�ir�;Ѽ���2�#�W�6)�:�m��C[�z�]ٖ�z�V�Vl��)e+z�D@	��y��7��^J��e����A
P�z����ox����:����o?L�53�:�k���
�(Ԝv��8ȥ�zh������G�}k��q��éDZ�����i�
��ro��۸=��"�
�jz��e������I����?h�O�~w?ӡ}:�<�Om�R�ON�s�ߴ̠��\�Lѡؠ���=!mFm@���{%�t�BʂUpuͦ��/��w�W�9\L"0Ii��i��-���H� c�v���@�����\F�־䵿�1�o#s:�c��+�$�.Ϋp;Gc*���K��T��yE�r�Ry�L�q"�\�P�t�Sۗ�~�<���Ha2�H��#x'4��VK�*z���{>MyM�͸�1���{�\�ɉ�6;Z8щ��jZQ|�0lXe�=�y�[s���̾�v����z�1`�2�<��Q���͸�qV"Ŋ\n��Y�x���@D�O��N�%wt<�ȍ��Yar�1�P�"�`�_k'���,!Q�!�	"ou�ZX �_^"�����'� �4�%D�H^�6,?�,7x(�P��I;iޟ���t2K!����t����<.�@d)������yB�1VK��:$�TPHrvC.!k�I´A�IWi�%I�k2I�1����7�*�C'���������f>[5OƤ�g0d^/E�R�ΝzX0ﷶi����(݌���F.�U����򖑋�/�h��2�B��뺿 *l	u      �   �   x�uν
�0�9y��@C~nҤ�A�.E�Ui:�
��tr�^Ǌ��7��R8۽��H���ӑS�:��%k��	8�"�FR�B�іk]���n�������U�<��-&xD�8?�\[��
����m1N�>)�~��q��kgDIFC�@��(�dX��9/�fO��j�	���LM坄b���oZB      �   �   x�3�<ܘ�������BF������
��V@dj�gjija	��2�,}�ky>-FV�z�榆�� =&�~��4虚���ԛr�=ܽ����f�� f��G��r/ �2c=SCS3�ob���� /�<\      �   �   x�3���(�|�k�B��ř
G&>ܽ�D���� �-tu��LCN�xCC�3���R�
V`�,fdlel�3���05�tt�s�2�n��!�nC$�8]�Ȱ��P������f�)v{�Q�E�%��15����� r�Zg      �   g   x��ϻ�0E�ڞ�������BT��T�^��#]�y}▘�EthD�:�*׶��s���@
%2O��xZ�zZT=M#�uO�fF��4�k      �   �   x���[JQ���*f=�rr}uR�A� ���"��
�<����s�B)D8�� ��ŌTh���;&_[9�Gqo�	��0�/c�`�����3L��K�0����\��}��T�
���X��������?���O���IJ�r72˝�v��7g��?s#v�o�"o=�:�S>�i���,w      �     x���Mj�@���S�����g[�(�dQ(z�[T��I������{ �C)����G(0����HhdM-֜���
֠�(;�2���yrH�p]�m����U���s��|�����՘K6����j(���ߌ[>������T"W�q��ܸ�d&��s^����3�.�|w�ݳJݔ]�KMN��J���<�U��)�Ј�X�UQ���M�V��UPC&/	w���QPG�[��Y�i#�!�T��;ߣ���8�/��v      �      x������ � �      �   	  x��U�jA}�~����M�6͛TQAD��ԗ���,6�i;+ͣ���)RD�m(�b�Z��K����?���N:	��B2s�Μ{�g[���ȮЀ�t�X%��qJ`��;%Q�>"�a^��s>O}؎D�����O#ܾ��_";����o�D��=~��T�u�����&��Nk�So8�V��ZVQ�Z� �E~��f1�$��oTc5Q��bZ(��v`t�O��͓�0�����6E�(�I���݌lE�d"��-1 ��A���R�>O�6=|�#Mٰ;?����E>K�1��@4P BE�L�-�y�eϰ��ɏ�.l��]�'�h�G���~�㒬�q��_��s`��vcOd7�Fop�/��}�L���8�g��<�Iu#	�@v�J�(�3OR
]��$\>��Uy�����ֲV�0�X�J*���ۚ�}��x#�k���}*����ָ������Qq
��r�1o�Tn�����`mQ�\�����*S����h �;�5�рg��U<�m�7z��ww'�It{M����D�"���uyگTѲ�6&l� ^��ɎA���*�R�*�Ҷܦ��v�g7�K�����#�x�m2I�v���ٯ*_��+R�!t�1�e�R!L=(gjpM��"�~�N C�iŚp��P2���1�/b8����@�.�d�*�9�4~�lmH�9�*^޼�Gvb�n����+MρGf�h�I��7(@�ў�g�wGэ�����}�ź�ukݱ,�?�B�      �   �   x��ҫ1�a��������EQ@HPt�ב594Ұ�>�CL �kO3FD�:�Ul��f��^<����y��`L*�)�L��`��e2d�R 8�7�b�ye,-��Ы�'ϐ#U/�#5��#u�#O�#M��"��.9��2)ԙB_M���      �   �  x���Y��@���W�Я]PEU�<:���N& � ����G{zz�1c����Tr>��C�qƲ� ��>��<���W�7?��Xl#�˼ ���/閛�i�ҭ��'9ς�1������g6N�(��ߵ�AC�����:|l/�C����(�W(�$x{���t�����؎���^.Yggǋ����V�R�OU��K�dc����4OL0ߤ,����y�.���Y���L���%ֿb�W�PP��� <�D�P*0dFu�0f�ۻ�2hm�y�I0�C�˖��X4���t��W������#M�>�t��1{�2��*a��T����<c�\o�j�|{+K�s\��X������Ե.���u�Qj�V�3���wGzk�k�kç�TA�X��o���{㈟'��
��:ŇR��������a]��٥�f���h=٘&{8�r��m��#��z���	I�P�e��y���E��X�Y~p�c=���Z�?��������T�G�K%}mZ��{-����<���eXH�( Y��,=���H�u+�:�D��!�� On�qh�j=�Vwּ�6��l-u��b~S�5�س3D����=���
���1��C��!����,d��=�q��^���E��ڤ�.�Z�j���6o��>����AVRo�Qx2��h�H��z|�Z^�H ���Ƚ��-}���T*?��z      �   x   x�}�;
�0��:wn�p^I���ŨD���.�����)��Yr�r��sS6��#���F�C�A�zR.���ӑ̶�a��@�����Mm�z���|)=U��IbE[j\)=M���l�7�      �   b   x�3�tv�����r�(M�S��H���Q����P��L-�Qp��d�s ��������������������������1>)G��0WNc�=... +�y      �   �  x����j�0��t$q1�Oi�M��DW(|���m�7ꍃ"��3��so�P݋���'JOT��6Y��Zs6y�D||U��L���#�E,N��c�Hfb��FGE#rv�����ض��X���j�]���: �#o"eUe�~��`��v�k����ק���a/��O�K���E&����֛�T,���c�duo��1�0o�R��:"�|�y��T�t֤���W �O$�!#�D�x��Bz"V<Q��'bÓp��'b��IΦ��>���)-_�;�}��i����iq�J˷�u��~�'�%/������DL Х���Eti
���2�)�MZj��1�m���

U�B��?|t��q�ض�=#�G�y��A���=#w���[�3A�      �     x�}�;n�0��>E/�o=��Ȑ���Nz�[T��(}�?���A\n׷�'.`���/�����N$/�S*��E�������i�Pb]%1`�E���y�P#h�F�E���e����}cMĔ��u�N1�E�I���<�� �:G�5��E�r�nC���㙃޵���G�\/C/�e�@��CK�M��d~D�ס׉��:YR��,�\G�u��}��}�F���D��t?�����~<t�oK�M�F������v�σ      �   S   x�3�t>�0���9�3̕Ӑ3Ə����B��R��R��������(�e�靎���@��T��������T�������<F��� ��      �   )	  x��ݱn7@���+\��r�\.�A�4��T���8w�`��+��!A#Dc�����<�G{|��QG���Z������s���Z�Z����(������>�������~�㟿����=Et���m��绦O�7jNz=�?�ب9����I�F�I��H�<i�5']I��mԜtm$}ҾQsҵ��I�F�I�F�'�'��F��Wݨ9��H��m��k5��������O:6jN�6�>�ܨ8�X�'u��k#银������O�7jN�~`�I�F�I�F�'�'��F�wݨ9��H��m��k#��������O:6jN�6�>�ܨ8�\�'�u��k#银������O�7jN�6�>�ب9��H��s�⤵��4�Qk�[Ug]Kɟ�mU�u�%־Uuֵ��Y�V�Y�j�g�[5gmk7����'�N���'L۞�:��O�0m��kC}´�ɪӮ�	��'kN{Ɩ�;��R�K���'L۞�:ml)��d�icK�ӎ'�N[ʟv>Ys�_�'��/G{k���^�<�����������CO�"�l�+�u6������w�l|o�����Y^t�{ŗ�ya.At�a9�g���^۸�y���?~�z�G$���"jr�3����`�5�x���#N��9�P���Eyǂk����k�H|\���9�1�k�q�WͻrYs�|}�-�h����I,�W�p�9"xq�;i���U�9.�.�8(��oJs�o;qMjv�$u�;�0ל�����e����xR�'�W��N׼�-Z�9�M�I�횄��YK�R�Y#�p͓'�.�y@�W\�qmt�;���9�ڨ��pMBg�<��蚝k��^\]tĵ�5�6��k�j��F׬qmtMމ��$��yqmt����E�6��k�j�%���Y���G\]�ŵ�5I�]spmtћk��θ6�f/qmt��F�<���-���yƵ�5{\]���袓k��^%���Y���G\]�ŵ�5ϸ6�f�k�k^qmt�|����µ�Ei�j�6�&m�k�6�&m�k�6�&m�j��6�h��.�NpM�FפmtM�FפmtM�FפmT͙m��f���|�&m�k�6�&m�k�6�&m�k�6�f+�6�h��.�ϊk�6�&m�k�6�&m�k�6�f�mt�l]4�F�[פmtM�FפmtM�F�<h]���5�mt�l]���TM�FפmtM�F�l���I�蚴���m��f�袴��I�蚴��y�6�&m�k�6�&m�kf���6�(m�k�6�f�mtM�FפmtM�Fפmt�l]4�F�mT͋��5i]���5i]���5i]3�FͶQEm�k�6�&m�k�6�&m�k�6�&m�kfۨ�w��.J��U���5i]���5i]���5iUsf���6�(m�kr�tM�FפmtM�FפmtM�F�<K��.�m���6�&�FפmtM�FפmtM�FפmT͚m��f�袴�����5i]���5i]��Q5�F�̶�E�mtQ�F��皴��I�蚴���h]���5�mt�l]���RM�FפmtM�F�<i]���5i]3�FͶ�Ei]���5iU��6�&m�k�6�&m�kf���6�(m�k�6��E�蚴��I�蚴��I���6�h��.Jۨ����5i]��,�I�蚴��I���6�h��*z�6�&m�k��&�\���5i]���5�mTљm���6դmtM�FפmtM�FפmtM�F��%�FͶ�Ei]���5i�\��f�I�蚴��Iۨ�5�FͶ�Ei]���5�\��I�I�蚴��Iۨ�G��.�m���6�&m�k�0�&m�k�6�&m�j6�F�̶�E�mtQ�FפmtM�FפmtM�F�<i]���5�mt�l]���VM�FפmtM�F�촍�I�蚴���m��f�袴��I�蚴��y�6�&m�k��k�6�f��.�m���6�&m�j�FפmtM���&;�5i]3�FͶ�EiU�mtM�FפmtM���&��5i]3�FͶQE'm�k�6�&m�k�6�&�B]��皴���m��^%�F�m��I�蚴��I�蚴��I�蚴��Y�mt�l]���5i]���5i]��̮I�蚴��yd���6�(m�k�6�&m�k�6�&m�k�6�&m�j�l]4�F�mtM�FפmtM�FפmtM�F�<i]3�FͶ�Ei]���5i]���5iU��6�&m�kf���6�(mc-*J�(�ԍ2J��}��8�(���f�(��8�*���R9�(���:G%t��,�]4O�.����f�(�Ԏ2J��7���<�h��ͬ�E���=�jV��J�袓�QF	e4��毞q�l�]4��.����f�����?�(����-�E��ûh�>� �E��뢙A�j�RU�������W      �      x�3�24�22����� ��      �   �   x���=
�0�g��@�~l�Ҝ��J�
��-�Li	di�=>�X	T�!�a���d��:iL�(�u�a���e|<�
\*4qڥ����MꑵO�j���
m��Cr.�s,ƈ�mQrd�S)�3\�yZn��Ck�����5������]�q*�+�>��h      �   �   x���1
A��zs���y��d�S��m���-e%��"���v�2#`Ǎ��*��e�����z���J��7�%93�Fił�_X��1#G��,w,o�2��0Whr��2J+Vȥc�I��h�7�L�DDO�`Y\      �   �   x���=
�0�Y9E.�'ɖ㭔�K���U�
-�S0�|<YnT*9��2��L¨0���&�� �E������ty9��P�E��`�C�X�3CK/:P'�;����}醕������Y]H~��c�s�%�Rm�E;Z�\�8���\ߨ6�OV�^���4��Ei�      �   1   x�3�4�w�p�7䬮".C$1c����)L�I�*���� ��O      �   �   x��ұ
�@�z�+������\r]��6*����0V�Bqa�e^3�,���lB����a#դ*�RX֢q{�_&c��x�M�[Dgt�3zKnz��g7~ e�OB�>�M�g=��62�h-z�#�9���G~��h�W^��8V���p��K     