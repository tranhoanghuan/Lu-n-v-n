PGDMP     -    /            	    v            luandry_schema    10.5    10.5 +   .           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            /           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            0           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            1           1262    26262    luandry_schema    DATABASE     �   CREATE DATABASE luandry_schema WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Vietnamese_Vietnam.1258' LC_CTYPE = 'Vietnamese_Vietnam.1258';
    DROP DATABASE luandry_schema;
             postgres    false                        2615    27026    auth_public    SCHEMA        CREATE SCHEMA auth_public;
    DROP SCHEMA auth_public;
             postgres    false            2           0    0    SCHEMA auth_public    ACL     n   GRANT USAGE ON SCHEMA auth_public TO auth_anonymous;
GRANT USAGE ON SCHEMA auth_public TO auth_authenticated;
                  postgres    false    7                        2615    27149    postgraphile_watch    SCHEMA     "   CREATE SCHEMA postgraphile_watch;
     DROP SCHEMA postgraphile_watch;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            3           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    5            4           0    0    SCHEMA public    ACL     4   GRANT USAGE ON SCHEMA public TO auth_authenticated;
                  postgres    false    5                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            5           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    26265    citext 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
    DROP EXTENSION citext;
                  false    5            6           0    0    EXTENSION citext    COMMENT     S   COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';
                       false    3                        3079    26351    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    5            7           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    2                       1247    27046    jwt    TYPE     R   CREATE TYPE auth_public.jwt AS (
	role text,
	user_id integer,
	user_type text
);
    DROP TYPE auth_public.jwt;
       auth_public       postgres    false    7            e           1255    27052    authenticate(text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.authenticate(email text, password text, user_type text) RETURNS auth_public.jwt
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
       auth_public       postgres    false    1    895    7            8           0    0 @   FUNCTION authenticate(email text, password text, user_type text)    ACL     �   GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_authenticated;
            auth_public       postgres    false    357                       1259    27032    user    TABLE     U  CREATE TABLE auth_public."user" (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text,
    created_at timestamp without time zone DEFAULT now(),
    user_type text,
    CONSTRAINT user_first_name_check CHECK ((char_length(first_name) < 80)),
    CONSTRAINT user_last_name_check CHECK ((char_length(last_name) < 80))
);
    DROP TABLE auth_public."user";
       auth_public         postgres    false    7            9           0    0    TABLE "user"    ACL     �   GRANT SELECT ON TABLE auth_public."user" TO auth_anonymous;
GRANT SELECT,DELETE,UPDATE ON TABLE auth_public."user" TO auth_authenticated;
            auth_public       postgres    false    267            f           1255    27053    current_user()    FUNCTION     �   CREATE FUNCTION auth_public."current_user"() RETURNS auth_public."user"
    LANGUAGE sql STABLE
    AS $$ 
  SELECT * 
  FROM auth_public.user 
  WHERE id = auth_public.current_user_id()
$$;
 ,   DROP FUNCTION auth_public."current_user"();
       auth_public       postgres    false    7    267            :           0    0    FUNCTION "current_user"()    ACL     �   GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_authenticated;
            auth_public       postgres    false    358            d           1255    27047    current_user_id()    FUNCTION     �   CREATE FUNCTION auth_public.current_user_id() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  SELECT current_setting('jwt.claims.user_id', true)::integer;
$$;
 -   DROP FUNCTION auth_public.current_user_id();
       auth_public       postgres    false    7            g           1255    27051 +   register_user(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) RETURNS auth_public."user"
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
       auth_public       postgres    false    7    267    1            ;           0    0 b   FUNCTION register_user(first_name text, last_name text, email text, user_type text, password text)    ACL     �   GRANT ALL ON FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) TO auth_anonymous;
            auth_public       postgres    false    359            h           1255    27150    notify_watchers_ddl()    FUNCTION     �  CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
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
       postgraphile_watch       postgres    false    11    1            i           1255    27151    notify_watchers_drop()    FUNCTION     _  CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
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
       postgraphile_watch       postgres    false    1    11            
           1259    27030    user_id_seq    SEQUENCE     �   CREATE SEQUENCE auth_public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth_public.user_id_seq;
       auth_public       postgres    false    267    7            <           0    0    user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE auth_public.user_id_seq OWNED BY auth_public."user".id;
            auth_public       postgres    false    266            �            1259    26408    bill_seq    SEQUENCE     q   CREATE SEQUENCE public.bill_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.bill_seq;
       public       postgres    false    5            �            1259    26410    bill    TABLE     �  CREATE TABLE public.bill (
    id numeric(19,0) DEFAULT nextval('public.bill_seq'::regclass) NOT NULL,
    receipt_id numeric(19,0),
    create_id numeric(19,0),
    shipper_id numeric(19,0),
    payment_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.bill;
       public         postgres    false    200    5            =           0    0 
   TABLE bill    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.bill TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    201            �            1259    26414    bill_detail_seq    SEQUENCE     x   CREATE SEQUENCE public.bill_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.bill_detail_seq;
       public       postgres    false    5            �            1259    26416    bill_detail    TABLE     2  CREATE TABLE public.bill_detail (
    id numeric(19,0) DEFAULT nextval('public.bill_detail_seq'::regclass) NOT NULL,
    bill_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount integer,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.bill_detail;
       public         postgres    false    202    5            >           0    0    TABLE bill_detail    ACL     s   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.bill_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    203            �            1259    26423 
   branch_seq    SEQUENCE     s   CREATE SEQUENCE public.branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.branch_seq;
       public       postgres    false    5            �            1259    26425    branch    TABLE     �  CREATE TABLE public.branch (
    id numeric(19,0) DEFAULT nextval('public.branch_seq'::regclass) NOT NULL,
    branch_name character varying(2000) NOT NULL,
    store_id numeric(19,0) NOT NULL,
    address character varying(4000),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone,
    status character varying(200),
    branch_avatar integer
);
    DROP TABLE public.branch;
       public         postgres    false    204    5            ?           0    0    TABLE branch    ACL     n   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    205            �            1259    26432 	   color_seq    SEQUENCE     r   CREATE SEQUENCE public.color_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.color_seq;
       public       postgres    false    5            �            1259    26434    color    TABLE     l  CREATE TABLE public.color (
    id numeric(19,0) DEFAULT nextval('public.color_seq'::regclass) NOT NULL,
    color_name character varying(2000),
    color_group_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.color;
       public         postgres    false    206    5            @           0    0    TABLE color    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.color TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    207            �            1259    26441    color_group_seq    SEQUENCE     x   CREATE SEQUENCE public.color_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.color_group_seq;
       public       postgres    false    5            �            1259    26443    color_group    TABLE     \  CREATE TABLE public.color_group (
    id numeric(19,0) DEFAULT nextval('public.color_group_seq'::regclass) NOT NULL,
    color_group_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.color_group;
       public         postgres    false    208    5            A           0    0    TABLE color_group    ACL     s   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.color_group TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    209            �            1259    26450    customer_seq    SEQUENCE     u   CREATE SEQUENCE public.customer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.customer_seq;
       public       postgres    false    5            �            1259    26452    customer    TABLE     �  CREATE TABLE public.customer (
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
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    customer_avatar integer
);
    DROP TABLE public.customer;
       public         postgres    false    210    5            B           0    0    TABLE customer    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.customer TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    211            �            1259    26459    customer_order_seq    SEQUENCE     {   CREATE SEQUENCE public.customer_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.customer_order_seq;
       public       postgres    false    5            �            1259    26461    customer_order    TABLE     �  CREATE TABLE public.customer_order (
    id numeric(19,0) DEFAULT nextval('public.customer_order_seq'::regclass) NOT NULL,
    customer_id numeric(19,0),
    branch_id numeric(19,0),
    pick_up_date date,
    pick_up_time_id numeric(19,0),
    delivery_date date,
    delivery_time_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 "   DROP TABLE public.customer_order;
       public         postgres    false    212    5            C           0    0    TABLE customer_order    ACL     v   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.customer_order TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    213            �            1259    26465    dry_seq    SEQUENCE     p   CREATE SEQUENCE public.dry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.dry_seq;
       public       postgres    false    5            �            1259    26467    dry    TABLE     b  CREATE TABLE public.dry (
    id numeric(19,0) DEFAULT nextval('public.dry_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    drying_machine_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.dry;
       public         postgres    false    214    5            D           0    0 	   TABLE dry    ACL     k   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.dry TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    215            �            1259    26471 	   dryer_seq    SEQUENCE     r   CREATE SEQUENCE public.dryer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.dryer_seq;
       public       postgres    false    5            �            1259    26473    dryer    TABLE     �  CREATE TABLE public.dryer (
    id numeric(19,0) DEFAULT nextval('public.dryer_seq'::regclass) NOT NULL,
    branch_id numeric(19,0),
    bought_date date,
    buyer numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    dryer_name character varying(2000)
);
    DROP TABLE public.dryer;
       public         postgres    false    216    5            E           0    0    TABLE dryer    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.dryer TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    217            �            1259    26480 	   label_seq    SEQUENCE     r   CREATE SEQUENCE public.label_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.label_seq;
       public       postgres    false    5            �            1259    26482    label    TABLE     J  CREATE TABLE public.label (
    id numeric(19,0) DEFAULT nextval('public.label_seq'::regclass) NOT NULL,
    label_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.label;
       public         postgres    false    218    5            F           0    0    TABLE label    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.label TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    219            �            1259    26489    material_seq    SEQUENCE     u   CREATE SEQUENCE public.material_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.material_seq;
       public       postgres    false    5            �            1259    26491    material    TABLE     S  CREATE TABLE public.material (
    id numeric(19,0) DEFAULT nextval('public.material_seq'::regclass) NOT NULL,
    material_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.material;
       public         postgres    false    220    5            G           0    0    TABLE material    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.material TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    221            �            1259    26498    order_detail_seq    SEQUENCE     y   CREATE SEQUENCE public.order_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.order_detail_seq;
       public       postgres    false    5            �            1259    26500    order_detail    TABLE     5  CREATE TABLE public.order_detail (
    id numeric(19,0) DEFAULT nextval('public.order_detail_seq'::regclass) NOT NULL,
    order_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount integer,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
     DROP TABLE public.order_detail;
       public         postgres    false    222    5            H           0    0    TABLE order_detail    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.order_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    223            �            1259    26507    payment_seq    SEQUENCE     t   CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.payment_seq;
       public       postgres    false    5            �            1259    26509    payment    TABLE     P  CREATE TABLE public.payment (
    id numeric(19,0) DEFAULT nextval('public.payment_seq'::regclass) NOT NULL,
    payment_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.payment;
       public         postgres    false    224    5            I           0    0    TABLE payment    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.payment TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    225            �            1259    26516    post    TABLE     t   CREATE TABLE public.post (
    id integer NOT NULL,
    headline text,
    body text,
    header_image_file text
);
    DROP TABLE public.post;
       public         postgres    false    5            J           0    0 
   TABLE post    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.post TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    226            �            1259    26522    post_id_seq    SEQUENCE     �   CREATE SEQUENCE public.post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.post_id_seq;
       public       postgres    false    5    226            K           0    0    post_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.post_id_seq OWNED BY public.post.id;
            public       postgres    false    227            L           0    0    SEQUENCE post_id_seq    ACL     R   GRANT ALL ON SEQUENCE public.post_id_seq TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    227            �            1259    26524    product_seq    SEQUENCE     t   CREATE SEQUENCE public.product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.product_seq;
       public       postgres    false    5            �            1259    26526    product    TABLE     �  CREATE TABLE public.product (
    id numeric(19,0) DEFAULT nextval('public.product_seq'::regclass) NOT NULL,
    product_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    product_image text,
    short_desc character varying(200),
    producy_type_id numeric(19,0),
    product_avatar integer
);
    DROP TABLE public.product;
       public         postgres    false    228    5            M           0    0    TABLE product    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    229            �            1259    26533    product_type_seq    SEQUENCE     y   CREATE SEQUENCE public.product_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.product_type_seq;
       public       postgres    false    5            �            1259    26535    product_type    TABLE     _  CREATE TABLE public.product_type (
    id numeric(19,0) DEFAULT nextval('public.product_type_seq'::regclass) NOT NULL,
    product_type_name character varying(2000),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone
);
     DROP TABLE public.product_type;
       public         postgres    false    230    5            N           0    0    TABLE product_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    231            �            1259    26542    promotion_seq    SEQUENCE     v   CREATE SEQUENCE public.promotion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.promotion_seq;
       public       postgres    false    5            �            1259    26544 	   promotion    TABLE     �  CREATE TABLE public.promotion (
    id numeric(19,0) DEFAULT nextval('public.promotion_seq'::regclass) NOT NULL,
    promotion_name character varying(2000),
    sale numeric(2,0),
    date_start date,
    date_end date,
    promotion_code character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.promotion;
       public         postgres    false    232    5            O           0    0    TABLE promotion    ACL     q   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    233            �            1259    26551    promotion_branch_seq    SEQUENCE     }   CREATE SEQUENCE public.promotion_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.promotion_branch_seq;
       public       postgres    false    5            �            1259    26553    promotion_branch    TABLE     u  CREATE TABLE public.promotion_branch (
    id numeric(19,0) DEFAULT nextval('public.promotion_branch_seq'::regclass) NOT NULL,
    promotion_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 $   DROP TABLE public.promotion_branch;
       public         postgres    false    234    5            P           0    0    TABLE promotion_branch    ACL     x   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    235            �            1259    26557    receipt_seq    SEQUENCE     t   CREATE SEQUENCE public.receipt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.receipt_seq;
       public       postgres    false    5            �            1259    26559    receipt    TABLE     �  CREATE TABLE public.receipt (
    id numeric(19,0) DEFAULT nextval('public.receipt_seq'::regclass) NOT NULL,
    order_id numeric(19,0),
    pick_up_time timestamp without time zone,
    delivery_time timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.receipt;
       public         postgres    false    236    5            Q           0    0    TABLE receipt    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    237            �            1259    26563    receipt_detail    TABLE       CREATE TABLE public.receipt_detail (
    id numeric(19,0) DEFAULT nextval('public.receipt_detail'::regclass) NOT NULL,
    receipt_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    amount integer,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 "   DROP TABLE public.receipt_detail;
       public         postgres    false    5            R           0    0    TABLE receipt_detail    ACL     v   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    238            �            1259    26567    receipt_detail_seq    SEQUENCE     {   CREATE SEQUENCE public.receipt_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.receipt_detail_seq;
       public       postgres    false    5            �            1259    26569    receipt_wash_bag_seq    SEQUENCE     }   CREATE SEQUENCE public.receipt_wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.receipt_wash_bag_seq;
       public       postgres    false    5            �            1259    26571    receipt_wash_bag    TABLE     u  CREATE TABLE public.receipt_wash_bag (
    id numeric(19,0) DEFAULT nextval('public.receipt_wash_bag_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    receipt_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 $   DROP TABLE public.receipt_wash_bag;
       public         postgres    false    240    5            S           0    0    TABLE receipt_wash_bag    ACL     x   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt_wash_bag TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    241            �            1259    26575    service_type_seq    SEQUENCE     y   CREATE SEQUENCE public.service_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.service_type_seq;
       public       postgres    false    5            �            1259    26577    service_type    TABLE     �  CREATE TABLE public.service_type (
    id numeric(19,0) DEFAULT nextval('public.service_type_seq'::regclass) NOT NULL,
    service_type_name character varying(2000),
    service_type_desc character varying(4000),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    service_type_avatar integer
);
     DROP TABLE public.service_type;
       public         postgres    false    242    5            T           0    0    TABLE service_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    243            �            1259    26584    service_type_branch_seq    SEQUENCE     �   CREATE SEQUENCE public.service_type_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.service_type_branch_seq;
       public       postgres    false    5            �            1259    26586    service_type_branch    TABLE     u  CREATE TABLE public.service_type_branch (
    id numeric(19,0) DEFAULT nextval('public.service_type_branch_seq'::regclass),
    service_type_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 '   DROP TABLE public.service_type_branch;
       public         postgres    false    244    5            U           0    0    TABLE service_type_branch    ACL     {   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    245            �            1259    26590 	   staff_seq    SEQUENCE     r   CREATE SEQUENCE public.staff_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.staff_seq;
       public       postgres    false    5            �            1259    26592    staff    TABLE     �  CREATE TABLE public.staff (
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
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    staff_type_id numeric(19,0),
    branch_id numeric(19,0),
    staff_avatar integer
);
    DROP TABLE public.staff;
       public         postgres    false    246    5            V           0    0    TABLE staff    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    247            �            1259    26599    staff_type_seq    SEQUENCE     w   CREATE SEQUENCE public.staff_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.staff_type_seq;
       public       postgres    false    5            �            1259    26601 
   staff_type    TABLE     Y  CREATE TABLE public.staff_type (
    id numeric(19,0) DEFAULT nextval('public.staff_type_seq'::regclass) NOT NULL,
    staff_type_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.staff_type;
       public         postgres    false    248    5            W           0    0    TABLE staff_type    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    249            �            1259    26608 	   store_seq    SEQUENCE     r   CREATE SEQUENCE public.store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.store_seq;
       public       postgres    false    5            �            1259    26610    store    TABLE     �  CREATE TABLE public.store (
    id numeric(19,0) DEFAULT nextval('public.store_seq'::regclass) NOT NULL,
    store_name character varying(2000),
    address character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    store_avatar integer
);
    DROP TABLE public.store;
       public         postgres    false    250    5            X           0    0    TABLE store    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.store TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    251            �            1259    26617    time_schedule_seq    SEQUENCE     z   CREATE SEQUENCE public.time_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.time_schedule_seq;
       public       postgres    false    5            �            1259    26619    time_schedule    TABLE     �  CREATE TABLE public.time_schedule (
    id numeric(19,0) DEFAULT nextval('public.time_schedule_seq'::regclass) NOT NULL,
    time_schedule_no character varying(200),
    time_start time without time zone,
    time_end time without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 !   DROP TABLE public.time_schedule;
       public         postgres    false    252    5            Y           0    0    TABLE time_schedule    ACL     u   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.time_schedule TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    253            �            1259    26623    unit_seq    SEQUENCE     q   CREATE SEQUENCE public.unit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.unit_seq;
       public       postgres    false    5            �            1259    26625    unit    TABLE     a  CREATE TABLE public.unit (
    id numeric(19,0) DEFAULT nextval('public.unit_seq'::regclass) NOT NULL,
    unit_name character varying(200) NOT NULL,
    status character varying(200),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone
);
    DROP TABLE public.unit;
       public         postgres    false    254    5            Z           0    0 
   TABLE unit    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    255                        1259    26629    unit_price_seq    SEQUENCE     w   CREATE SEQUENCE public.unit_price_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.unit_price_seq;
       public       postgres    false    5                       1259    26631 
   unit_price    TABLE     �  CREATE TABLE public.unit_price (
    id numeric(19,0) DEFAULT nextval('public.unit_price_seq'::regclass) NOT NULL,
    product_id numeric(19,0),
    service_type_id numeric(19,0),
    material_id numeric(19,0),
    unit_id numeric(19,0),
    apply_date timestamp without time zone,
    price money,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.unit_price;
       public         postgres    false    256    5            [           0    0    TABLE unit_price    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit_price TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    257                       1259    26635    wash_seq    SEQUENCE     q   CREATE SEQUENCE public.wash_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.wash_seq;
       public       postgres    false    5                       1259    26637    wash    TABLE     e  CREATE TABLE public.wash (
    id numeric(19,0) DEFAULT nextval('public.wash_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    washing_machine_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.wash;
       public         postgres    false    258    5            \           0    0 
   TABLE wash    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    259                       1259    26641    wash_bag_seq    SEQUENCE     u   CREATE SEQUENCE public.wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.wash_bag_seq;
       public       postgres    false    5                       1259    26643    wash_bag    TABLE     R  CREATE TABLE public.wash_bag (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_seq'::regclass) NOT NULL,
    wash_bag_name character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.wash_bag;
       public         postgres    false    260    5            ]           0    0    TABLE wash_bag    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    261                       1259    26647    wash_bag_detail_seq    SEQUENCE     |   CREATE SEQUENCE public.wash_bag_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.wash_bag_detail_seq;
       public       postgres    false    5                       1259    26649    wash_bag_detail    TABLE       CREATE TABLE public.wash_bag_detail (
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
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 #   DROP TABLE public.wash_bag_detail;
       public         postgres    false    262    5            ^           0    0    TABLE wash_bag_detail    ACL     w   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    263                       1259    26653    washing_machine_seq    SEQUENCE     |   CREATE SEQUENCE public.washing_machine_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.washing_machine_seq;
       public       postgres    false    5            	           1259    26655    washing_machine    TABLE     �  CREATE TABLE public.washing_machine (
    id numeric(19,0) DEFAULT nextval('public.washing_machine_seq'::regclass) NOT NULL,
    branch_id numeric(19,0),
    bought_date date,
    buyer numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 #   DROP TABLE public.washing_machine;
       public         postgres    false    264    5            _           0    0    TABLE washing_machine    ACL     w   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.washing_machine TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    265            �           2604    27035    user id    DEFAULT     n   ALTER TABLE ONLY auth_public."user" ALTER COLUMN id SET DEFAULT nextval('auth_public.user_id_seq'::regclass);
 =   ALTER TABLE auth_public."user" ALTER COLUMN id DROP DEFAULT;
       auth_public       postgres    false    267    266    267            �           2604    26660    post id    DEFAULT     b   ALTER TABLE ONLY public.post ALTER COLUMN id SET DEFAULT nextval('public.post_id_seq'::regclass);
 6   ALTER TABLE public.post ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    227    226            +          0    27032    user 
   TABLE DATA               W   COPY auth_public."user" (id, first_name, last_name, created_at, user_type) FROM stdin;
    auth_public       postgres    false    267   ��      �          0    26410    bill 
   TABLE DATA               �   COPY public.bill (id, receipt_id, create_id, shipper_id, payment_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    201   �      �          0    26416    bill_detail 
   TABLE DATA               �   COPY public.bill_detail (id, bill_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    203   �      �          0    26425    branch 
   TABLE DATA               �   COPY public.branch (id, branch_name, store_id, address, create_by, update_by, create_date, update_date, status, branch_avatar) FROM stdin;
    public       postgres    false    205   �      �          0    26434    color 
   TABLE DATA               w   COPY public.color (id, color_name, color_group_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    207   ;�      �          0    26443    color_group 
   TABLE DATA               s   COPY public.color_group (id, color_group_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    209   �      �          0    26452    customer 
   TABLE DATA               �   COPY public.customer (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, customer_avatar) FROM stdin;
    public       postgres    false    211   f�      �          0    26461    customer_order 
   TABLE DATA               �   COPY public.customer_order (id, customer_id, branch_id, pick_up_date, pick_up_time_id, delivery_date, delivery_time_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    213   "�      �          0    26467    dry 
   TABLE DATA               y   COPY public.dry (id, wash_bag_id, drying_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    215   ?�      �          0    26473    dryer 
   TABLE DATA               �   COPY public.dryer (id, branch_id, bought_date, buyer, create_by, update_by, create_date, update_date, status, dryer_name) FROM stdin;
    public       postgres    false    217   \�      �          0    26482    label 
   TABLE DATA               g   COPY public.label (id, label_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    219   y�      �          0    26491    material 
   TABLE DATA               m   COPY public.material (id, material_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    221   L�      �          0    26500    order_detail 
   TABLE DATA               �   COPY public.order_detail (id, order_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    223   (�                0    26509    payment 
   TABLE DATA               k   COPY public.payment (id, payment_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    225   E�                0    26516    post 
   TABLE DATA               E   COPY public.post (id, headline, body, header_image_file) FROM stdin;
    public       postgres    false    226   b�                0    26526    product 
   TABLE DATA               �   COPY public.product (id, product_name, create_by, update_by, create_date, update_date, status, product_image, short_desc, producy_type_id, product_avatar) FROM stdin;
    public       postgres    false    229   ��                0    26535    product_type 
   TABLE DATA               u   COPY public.product_type (id, product_type_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    231   {�      	          0    26544 	   promotion 
   TABLE DATA               �   COPY public.promotion (id, promotion_name, sale, date_start, date_end, promotion_code, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    233   �                0    26553    promotion_branch 
   TABLE DATA                  COPY public.promotion_branch (id, promotion_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    235   3�                0    26559    receipt 
   TABLE DATA               �   COPY public.receipt (id, order_id, pick_up_time, delivery_time, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    237   P�                0    26563    receipt_detail 
   TABLE DATA               �   COPY public.receipt_detail (id, receipt_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    238   m�                0    26571    receipt_wash_bag 
   TABLE DATA                  COPY public.receipt_wash_bag (id, wash_bag_id, receipt_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    241   ��                0    26577    service_type 
   TABLE DATA               �   COPY public.service_type (id, service_type_name, service_type_desc, status, create_by, update_by, create_date, update_date, service_type_avatar) FROM stdin;
    public       postgres    false    243   ��                0    26586    service_type_branch 
   TABLE DATA               �   COPY public.service_type_branch (id, service_type_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    245   (�                0    26592    staff 
   TABLE DATA               �   COPY public.staff (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, staff_type_id, branch_id, staff_avatar) FROM stdin;
    public       postgres    false    247   E�                0    26601 
   staff_type 
   TABLE DATA               q   COPY public.staff_type (id, staff_type_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    249   ×                0    26610    store 
   TABLE DATA               ~   COPY public.store (id, store_name, address, create_by, update_by, create_date, update_date, status, store_avatar) FROM stdin;
    public       postgres    false    251   ��                0    26619    time_schedule 
   TABLE DATA               �   COPY public.time_schedule (id, time_schedule_no, time_start, time_end, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    253   ��                0    26625    unit 
   TABLE DATA               e   COPY public.unit (id, unit_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    255   �      !          0    26631 
   unit_price 
   TABLE DATA               �   COPY public.unit_price (id, product_id, service_type_id, material_id, unit_id, apply_date, price, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    257   }�      #          0    26637    wash 
   TABLE DATA               {   COPY public.wash (id, wash_bag_id, washing_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    259   z�      %          0    26643    wash_bag 
   TABLE DATA               m   COPY public.wash_bag (id, wash_bag_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    261   ��      '          0    26649    wash_bag_detail 
   TABLE DATA               �   COPY public.wash_bag_detail (id, wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    263   ��      )          0    26655    washing_machine 
   TABLE DATA               �   COPY public.washing_machine (id, branch_id, bought_date, buyer, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    265   њ      `           0    0    user_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('auth_public.user_id_seq', 4, true);
            auth_public       postgres    false    266            a           0    0    bill_detail_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.bill_detail_seq', 1, false);
            public       postgres    false    202            b           0    0    bill_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.bill_seq', 1, false);
            public       postgres    false    200            c           0    0 
   branch_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.branch_seq', 1, false);
            public       postgres    false    204            d           0    0    color_group_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.color_group_seq', 2, true);
            public       postgres    false    208            e           0    0 	   color_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.color_seq', 7, true);
            public       postgres    false    206            f           0    0    customer_order_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.customer_order_seq', 1, false);
            public       postgres    false    212            g           0    0    customer_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.customer_seq', 3, true);
            public       postgres    false    210            h           0    0    dry_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.dry_seq', 1, false);
            public       postgres    false    214            i           0    0 	   dryer_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.dryer_seq', 1, false);
            public       postgres    false    216            j           0    0 	   label_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.label_seq', 9, true);
            public       postgres    false    218            k           0    0    material_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.material_seq', 10, true);
            public       postgres    false    220            l           0    0    order_detail_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.order_detail_seq', 1, false);
            public       postgres    false    222            m           0    0    payment_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.payment_seq', 1, false);
            public       postgres    false    224            n           0    0    post_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.post_id_seq', 18, true);
            public       postgres    false    227            o           0    0    product_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.product_seq', 6, true);
            public       postgres    false    228            p           0    0    product_type_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.product_type_seq', 6, true);
            public       postgres    false    230            q           0    0    promotion_branch_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.promotion_branch_seq', 1, false);
            public       postgres    false    234            r           0    0    promotion_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.promotion_seq', 1, false);
            public       postgres    false    232            s           0    0    receipt_detail_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.receipt_detail_seq', 1, false);
            public       postgres    false    239            t           0    0    receipt_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.receipt_seq', 1, false);
            public       postgres    false    236            u           0    0    receipt_wash_bag_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.receipt_wash_bag_seq', 1, false);
            public       postgres    false    240            v           0    0    service_type_branch_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.service_type_branch_seq', 1, false);
            public       postgres    false    244            w           0    0    service_type_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.service_type_seq', 13, true);
            public       postgres    false    242            x           0    0 	   staff_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.staff_seq', 1, false);
            public       postgres    false    246            y           0    0    staff_type_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.staff_type_seq', 1, false);
            public       postgres    false    248            z           0    0 	   store_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.store_seq', 1, false);
            public       postgres    false    250            {           0    0    time_schedule_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.time_schedule_seq', 1, false);
            public       postgres    false    252            |           0    0    unit_price_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.unit_price_seq', 39, true);
            public       postgres    false    256            }           0    0    unit_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.unit_seq', 4, true);
            public       postgres    false    254            ~           0    0    wash_bag_detail_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.wash_bag_detail_seq', 1, false);
            public       postgres    false    262                       0    0    wash_bag_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.wash_bag_seq', 1, false);
            public       postgres    false    260            �           0    0    wash_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.wash_seq', 1, false);
            public       postgres    false    258            �           0    0    washing_machine_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.washing_machine_seq', 1, false);
            public       postgres    false    264            /           2606    27043    user user_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY auth_public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 ?   ALTER TABLE ONLY auth_public."user" DROP CONSTRAINT user_pkey;
       auth_public         postgres    false    267            �           2606    26664    bill_detail bill_detail_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT bill_detail_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT bill_detail_pkey;
       public         postgres    false    203            �           2606    26666    bill bill_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.bill DROP CONSTRAINT bill_pkey;
       public         postgres    false    201            �           2606    26668    branch branch_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_pkey;
       public         postgres    false    205            �           2606    26670    color_group color_group_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.color_group
    ADD CONSTRAINT color_group_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.color_group DROP CONSTRAINT color_group_pkey;
       public         postgres    false    209            �           2606    26672    color color_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.color DROP CONSTRAINT color_pkey;
       public         postgres    false    207            �           2606    26674 "   customer_order customer_order_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT customer_order_pkey;
       public         postgres    false    213            �           2606    26676    customer customer_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_pkey;
       public         postgres    false    211            �           2606    26678    dry dry_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT dry_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.dry DROP CONSTRAINT dry_pkey;
       public         postgres    false    215            �           2606    26680    dryer dryer_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT dryer_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.dryer DROP CONSTRAINT dryer_pkey;
       public         postgres    false    217                       2606    26682    label label_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.label DROP CONSTRAINT label_pkey;
       public         postgres    false    219                       2606    26684    material material_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.material DROP CONSTRAINT material_pkey;
       public         postgres    false    221                       2606    26686    order_detail order_detail_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT order_detail_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT order_detail_pkey;
       public         postgres    false    223                       2606    26688    payment payment_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.payment DROP CONSTRAINT payment_pkey;
       public         postgres    false    225            	           2606    26690    post post_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.post DROP CONSTRAINT post_pkey;
       public         postgres    false    226                       2606    26692    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public         postgres    false    229                       2606    26694    product_type product_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_type DROP CONSTRAINT product_type_pkey;
       public         postgres    false    231                       2606    26696 &   promotion_branch promotion_branch_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT promotion_branch_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT promotion_branch_pkey;
       public         postgres    false    235                       2606    26698    promotion promotion_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public         postgres    false    233                       2606    26700 "   receipt_detail receipt_detail_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT receipt_detail_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT receipt_detail_pkey;
       public         postgres    false    238                       2606    26702    receipt receipt_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.receipt DROP CONSTRAINT receipt_pkey;
       public         postgres    false    237                       2606    26704 &   receipt_wash_bag receipt_wash_bag_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT receipt_wash_bag_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT receipt_wash_bag_pkey;
       public         postgres    false    241                       2606    26706    service_type service_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_pkey;
       public         postgres    false    243                       2606    26708    staff staff_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public         postgres    false    247                       2606    26710    staff_type staff_type_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.staff_type
    ADD CONSTRAINT staff_type_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.staff_type DROP CONSTRAINT staff_type_pkey;
       public         postgres    false    249                       2606    26712    store store_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.store DROP CONSTRAINT store_pkey;
       public         postgres    false    251            !           2606    26714     time_schedule time_schedule_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.time_schedule
    ADD CONSTRAINT time_schedule_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.time_schedule DROP CONSTRAINT time_schedule_pkey;
       public         postgres    false    253            #           2606    26716    unit unit_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.unit DROP CONSTRAINT unit_pkey;
       public         postgres    false    255            %           2606    26718    unit_price unit_price_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT unit_price_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT unit_price_pkey;
       public         postgres    false    257            +           2606    26720 $   wash_bag_detail wash_bag_detail_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT wash_bag_detail_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT wash_bag_detail_pkey;
       public         postgres    false    263            )           2606    26722    wash_bag wash_bag_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.wash_bag
    ADD CONSTRAINT wash_bag_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.wash_bag DROP CONSTRAINT wash_bag_pkey;
       public         postgres    false    261            '           2606    26724    wash wash_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT wash_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.wash DROP CONSTRAINT wash_pkey;
       public         postgres    false    259            -           2606    26726 $   washing_machine washing_machine_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.washing_machine
    ADD CONSTRAINT washing_machine_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.washing_machine DROP CONSTRAINT washing_machine_pkey;
       public         postgres    false    265            ;           2606    26727     branch branch_branch_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_avatar_fkey FOREIGN KEY (branch_avatar) REFERENCES public.post(id);
 J   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_branch_avatar_fkey;
       public       postgres    false    205    3081    226            >           2606    26732 &   customer customer_customer_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_customer_avatar_fkey FOREIGN KEY (customer_avatar) REFERENCES public.post(id);
 P   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_customer_avatar_fkey;
       public       postgres    false    211    226    3081            0           2606    26737    bill fk_bill_create_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_create_id FOREIGN KEY (create_id) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_create_id;
       public       postgres    false    3099    247    201            4           2606    26742 "   bill_detail fk_bill_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_bill_id FOREIGN KEY (bill_id) REFERENCES public.bill(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_bill_id;
       public       postgres    false    203    3055    201            5           2606    26747 #   bill_detail fk_bill_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_color_id;
       public       postgres    false    207    3061    203            6           2606    26752 #   bill_detail fk_bill_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_label_id;
       public       postgres    false    219    203    3073            7           2606    26757 &   bill_detail fk_bill_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 P   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_material_id;
       public       postgres    false    221    203    3075            8           2606    26762 %   bill_detail fk_bill_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 O   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_product_id;
       public       postgres    false    203    229    3083            9           2606    26767 *   bill_detail fk_bill_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 T   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_service_type_id;
       public       postgres    false    203    3097    243            :           2606    26772 "   bill_detail fk_bill_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_id;
       public       postgres    false    255    203    3107            1           2606    26777    bill fk_bill_payment_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_payment_id FOREIGN KEY (payment_id) REFERENCES public.payment(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_payment_id;
       public       postgres    false    201    3079    225            2           2606    26782    bill fk_bill_receipt_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_receipt_id;
       public       postgres    false    201    237    3091            3           2606    26787    bill fk_bill_shipper_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_shipper_id FOREIGN KEY (shipper_id) REFERENCES public.staff(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_shipper_id;
       public       postgres    false    201    247    3099            [           2606    26792    staff fk_branch_id    FK CONSTRAINT     t   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 <   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_branch_id;
       public       postgres    false    247    205    3059            <           2606    26797    branch fk_branch_store_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT fk_branch_store_id FOREIGN KEY (store_id) REFERENCES public.store(id);
 C   ALTER TABLE ONLY public.branch DROP CONSTRAINT fk_branch_store_id;
       public       postgres    false    3103    251    205            =           2606    26802    color fk_color_color_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.color
    ADD CONSTRAINT fk_color_color_group_id FOREIGN KEY (color_group_id) REFERENCES public.color_group(id);
 G   ALTER TABLE ONLY public.color DROP CONSTRAINT fk_color_color_group_id;
       public       postgres    false    209    207    3063            ?           2606    26807 *   customer_order fk_customer_order_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 T   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_branch_id;
       public       postgres    false    213    3059    205            @           2606    26812 ,   customer_order fk_customer_order_customer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 V   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_customer_id;
       public       postgres    false    211    3065    213            A           2606    26817 1   customer_order fk_customer_order_delivery_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_delivery_time_id FOREIGN KEY (delivery_time_id) REFERENCES public.time_schedule(id);
 [   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_delivery_time_id;
       public       postgres    false    213    3105    253            B           2606    26822 0   customer_order fk_customer_order_pick_up_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_pick_up_time_id FOREIGN KEY (pick_up_time_id) REFERENCES public.time_schedule(id);
 Z   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_pick_up_time_id;
       public       postgres    false    213    3105    253            C           2606    26827     dry fk_dry_dry_drying_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_dry_drying_machine_id FOREIGN KEY (drying_machine_id) REFERENCES public.dryer(id);
 J   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_dry_drying_machine_id;
       public       postgres    false    217    215    3071            D           2606    26832    dry fk_dry_wash_bag_id    FK CONSTRAINT     |   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 @   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_wash_bag_id;
       public       postgres    false    3113    215    261            E           2606    26837    dryer fk_dryer_branch_id    FK CONSTRAINT     z   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT fk_dryer_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 B   ALTER TABLE ONLY public.dryer DROP CONSTRAINT fk_dryer_branch_id;
       public       postgres    false    217    205    3059            F           2606    26842 %   order_detail fk_order_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_label_id;
       public       postgres    false    219    223    3073            G           2606    26847 %   order_detail fk_order_detail_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_order_id;
       public       postgres    false    3067    213    223            H           2606    26852 ,   order_detail fk_order_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 V   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_service_type_id;
       public       postgres    false    243    223    3097            I           2606    26857 $   order_detail fk_order_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 N   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_id;
       public       postgres    false    223    255    3107            J           2606    26862 "   product fk_product_product_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT fk_product_product_type_id FOREIGN KEY (producy_type_id) REFERENCES public.product_type(id);
 L   ALTER TABLE ONLY public.product DROP CONSTRAINT fk_product_product_type_id;
       public       postgres    false    3085    231    229            L           2606    26867 .   promotion_branch fk_promotion_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 X   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_branch_id;
       public       postgres    false    3059    235    205            M           2606    26872 1   promotion_branch fk_promotion_branch_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 [   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_promotion_id;
       public       postgres    false    233    235    3087            O           2606    26877 (   receipt_detail fk_receipt_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_bill_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_bill_id;
       public       postgres    false    3091    238    237            P           2606    26882 )   receipt_detail fk_receipt_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_color_id;
       public       postgres    false    3061    238    207            Q           2606    26887 )   receipt_detail fk_receipt_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_label_id;
       public       postgres    false    238    219    3073            R           2606    26892 ,   receipt_detail fk_receipt_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 V   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_material_id;
       public       postgres    false    221    3075    238            S           2606    26897 +   receipt_detail fk_receipt_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 U   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_product_id;
       public       postgres    false    238    3083    229            T           2606    26902 0   receipt_detail fk_receipt_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 Z   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_service_type_id;
       public       postgres    false    3097    243    238            U           2606    26907 (   receipt_detail fk_receipt_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_id;
       public       postgres    false    255    238    3107            N           2606    26912    receipt fk_receipt_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 E   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_order_id;
       public       postgres    false    3067    213    237            V           2606    26917 /   receipt_wash_bag fk_receipt_wash_bag_receipt_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 Y   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_receipt_id;
       public       postgres    false    241    3091    237            W           2606    26922 0   receipt_wash_bag fk_receipt_wash_bag_wash_bag_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 Z   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_wash_bag_id;
       public       postgres    false    3113    261    241            Y           2606    26927 4   service_type_branch fk_service_type_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 ^   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_branch_id;
       public       postgres    false    3059    245    205            Z           2606    26932 :   service_type_branch fk_service_type_branch_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 d   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_service_type_id;
       public       postgres    false    243    3097    245            \           2606    26937    staff fk_staff_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_type_id FOREIGN KEY (staff_type_id) REFERENCES public.staff_type(id);
 @   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_staff_type_id;
       public       postgres    false    247    3101    249            _           2606    26942 #   unit_price fk_unit_price_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 M   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_product_id;
       public       postgres    false    229    257    3083            `           2606    26947 (   unit_price fk_unit_price_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 R   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_service_type_id;
       public       postgres    false    257    243    3097            a           2606    26952     unit_price fk_unit_price_unit_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 J   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_unit_id;
       public       postgres    false    3107    255    257            d           2606    26957 *   wash_bag_detail fk_wash_bag_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_bill_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_bill_id;
       public       postgres    false    263    261    3113            e           2606    26962 +   wash_bag_detail fk_wash_bag_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_color_id;
       public       postgres    false    207    3061    263            f           2606    26967 +   wash_bag_detail fk_wash_bag_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_label_id;
       public       postgres    false    3073    263    219            g           2606    26972 .   wash_bag_detail fk_wash_bag_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 X   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_material_id;
       public       postgres    false    221    263    3075            h           2606    26977 -   wash_bag_detail fk_wash_bag_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_product_id;
       public       postgres    false    229    263    3083            i           2606    26982 2   wash_bag_detail fk_wash_bag_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 \   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_service_type_id;
       public       postgres    false    3097    243    263            j           2606    26987 *   wash_bag_detail fk_wash_bag_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_unit_id;
       public       postgres    false    3107    255    263            b           2606    26992    wash fk_wash_wash_bag_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 B   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_bag_id;
       public       postgres    false    3113    261    259            c           2606    26997 $   wash fk_wash_wash_washing_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_washing_machine_id FOREIGN KEY (washing_machine_id) REFERENCES public.washing_machine(id);
 N   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_washing_machine_id;
       public       postgres    false    265    259    3117            K           2606    27002 #   product product_product_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_product_avatar_fkey FOREIGN KEY (product_avatar) REFERENCES public.post(id);
 M   ALTER TABLE ONLY public.product DROP CONSTRAINT product_product_avatar_fkey;
       public       postgres    false    3081    229    226            X           2606    27007 2   service_type service_type_service_type_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_service_type_avatar_fkey FOREIGN KEY (service_type_avatar) REFERENCES public.post(id);
 \   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_service_type_avatar_fkey;
       public       postgres    false    243    226    3081            ]           2606    27012    staff staff_staff_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_staff_avatar_fkey FOREIGN KEY (staff_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_staff_avatar_fkey;
       public       postgres    false    3081    247    226            ^           2606    27017    store store_store_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_store_avatar_fkey FOREIGN KEY (store_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.store DROP CONSTRAINT store_store_avatar_fkey;
       public       postgres    false    3081    251    226            �           3466    27152    postgraphile_watch_ddl    EVENT TRIGGER       CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_ddl();
 +   DROP EVENT TRIGGER postgraphile_watch_ddl;
             postgres    false    360            �           3466    27153    postgraphile_watch_drop    EVENT TRIGGER     y   CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_drop();
 ,   DROP EVENT TRIGGER postgraphile_watch_drop;
             postgres    false    361            �           3256    27050    user delete_user    POLICY        CREATE POLICY delete_user ON auth_public."user" FOR DELETE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY delete_user ON auth_public."user";
       auth_public       postgres    false    267    356    267            �           3256    27048    user select_user    POLICY     I   CREATE POLICY select_user ON auth_public."user" FOR SELECT USING (true);
 /   DROP POLICY select_user ON auth_public."user";
       auth_public       postgres    false    267            �           3256    27049    user update_user    POLICY        CREATE POLICY update_user ON auth_public."user" FOR UPDATE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY update_user ON auth_public."user";
       auth_public       postgres    false    356    267    267            �           0    27032    user    ROW SECURITY     9   ALTER TABLE auth_public."user" ENABLE ROW LEVEL SECURITY;            auth_public       postgres    false            +   G   x�3��(=�(�3����y
��������������������������	griqI~njQ|IeA*W� ��t      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�}�M
�0�us
/А����Cx�n��YH+�B��{qo��"���(d��솏a�����\��R@Qm�� [�(�6(�2�w�H��ֻ�pjFy�C����h�@a�߯��[�\��&UѶ�x[�Jrkɪt��O�P`qc	�@a�C:/7��\�����V��`J���3ƾ��l�      �   U   x�3��=��T���¼t�?220��54�54U02�21�25ѳ46654�&&�d��rA��<�=1�>K=KCC$}1z\\\ �7      �   �   x�3�)z�ky��G��EP�3�41/�������ܡ��4%5�D/��T/5�T�,�3ƏS�(Q��L���$/3��3��ث��9�55�ë��"3�+��(+%*%�-;�<�(0ͫ8�,"�ԳЌ3��lgHƱ����f�&�F� s�"#C]C]Cc##+c+CcNC3�=... su9�      �      x������ � �      �      x������ � �      �      x������ � �      �   �   x�uϹjA��Z�y���aY�1^��C���8�J|�ü�M�p�A��i��"��23���������u(�ۥ~��g��%��}��Q8���!�9��4���Ͻv��i�e���G��!�Ũ�P�}��=#	%8/�+>�RzB#&��+��^Ʃ��#�נ���)�L��`�!'����iz      �   �   x�u�1�A�:{
/`�$3��m�T,�l���[���;��Xi�I�&.���	�>���X�x�����O�}ß�kʎҒܒ����s!d5F`�W� �&6��v�_�*ɨ�$yCl��P���d��Y��&|@�1&1"º�A��9�`7���i�GV�!�a?���E�}\k�<fU��Ƚ�y��(-�\d���yNYz�      �      x������ � �            x������ � �         9  x��T�j�0]����d�-+:t覛nA�k��K���뫤�:	�@R��B��}�T?�4�����Ͱ7al\�W�,��8{R�u�q�m�KP�����j�;��t���d3Wf�s�f���-ͧ��&m��IV��"�Ema�� -���d�-n�c�Z�I��F�!B���f��Z��z)���#\�o�(FL!�x�w��gxo�����ʷ	��.>Oi�_�f�1������3z���&/�؟�w��朖˶���,plL3�8�`RX�������%�C��L7&�%��������O/8�-٤i�h�|�̇��t�QJS:M=�RtH+�#-�k��K.k����J�C�@\[���Qd���R =.�Uξ�����:/r�a+�p�#NG�xY�!�^�4�5�ն�Z�1�\m��z��h^�ks��1�S��T��\Z9lH���r�V�9�rNq�YM��D����%9� K��n�����ʩ���5�HgQ�0GFzɩ �v��S�i�~u��|���G����xp»r�^Iı��*H����H�7M]�?�zs9         �   x�uн�0�<E_����vu7qgi4�$q4>	�#;�߃7ђ8!���_�V������U�uW��8x��C8e:f4f3c���DQ�2T]֖]�kELG.�����;����h�S+G�ͺ�i����� X!� 碞���9l9H"��dp����K�J �b5��tJ�(� 3�^         �   x�3�<ܘϙ�\�Y���BF������
��V@dj�gjija	��2�,}�ky>-FV�z�榆�� =&�~��4虚���ԛr�=ܽ����f�� f��G��r/ �2c=SCS3�ob���� `G@      	      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �         q  x����j�@ǯӧ8���n�u/mQ/D�
��f��Lhv��N��/t�"�n�R*��	"8K�c��s&��,�E�,�=3��~�L׹Ɇ�!wn�:�)Ap&xV����D ����DgG�$.�9�C{�~.�a��L���&^����ԉl�э�:����z�݄�l��7 ��엾�߇.ܮޝ�F�y0	��!�q��Χ;�GW��:;��:��o�4����Sc��(���d��;w�o��Y��i_�t���-]�ݕ����2Y;�K�z̶�2������Չ�멒rV:	�z�;��GR��$]~�^Q��(i��Ug=�l��	z<I�'qA��"F:?d.�^��"��"��-�?��qKHJߒ�����?(LF�Dа�kκ/�!]�{Q2,J[ScS��0>J�0�~��x�Z��j�����	����P�n[�U�G�/˒6դOJ���,���V&�����Pg�AΞ�Vx���F:;�dG�ZXe;�4���S/%��1;,}����~v���eSx���>�Ka-ȴ���R:G
�$���*ᗰ]��4�g5�2%����eKP���f�8h���(����y"_T���_Z���و::��g#�Q��?.ܡި��P�/.ڽj�w�K�x�A�}Eg}5IV�i;k�V�1��	Z��	�qXp�TW%,f�V%B�6�8K��6n[�c�z�ɐs9 @���hړNi�⁅�2o��dR0�h�4���܈����fU��Զ�9~�i������,Z��ei5���u!^h�g0iUa9�J��8uq�}4��IA�RL�u,H�����i�2�m�j��p$� W#�/�waa����            x������ � �         n   x�3���,�(��K/���H�L�34rH�M���K��ɪ%���y8z�U�:�z:�V��W�襺g���y�fY������y�'e���:�����b���� �*            x������ � �            x������ � �            x������ � �         S   x�3�t>�0�31�$�,�Ӑ3Ə����B��R��R��������(�e�靎���@��T��������T�������<F��� M�>      !   �  x���ˍ1�\��
|�9E���,9������RI�u2�bFc����gB�.�'���ʝx��1fkB�I2 |����;�~�������o7q�o�\��?�cz�5�N��*#������[�Β���������5�^(��U]8�8��h9�u�~EjeA�頣W>�2��%}���+��	����{:��:�5Si�V�=��^R���a��x�dF:��oU�u����,�{8���.#^� �M0��)_���Щw̩.��DL���9���;f��\��]w�1�^y=�Ѳ(]w�1�^y;שd&嵃����nH:��?�k��t��H������tLL�_c�|�*�O�c:��y��ɄV��Ӂ���9_طA-@K�H��7$}��/h�2�`���~Lދ�<x>�**�������V��OJ-k�������Ծc��|{\�9��c1������=�[�]��lI��k��nZ{�      #      x������ � �      %      x������ � �      '      x������ � �      )      x������ � �     