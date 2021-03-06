PGDMP         $            	    v            luandry_schema_21092018    10.4    10.4 +   .           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            /           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            0           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            1           1262    19685    luandry_schema_21092018    DATABASE     �   CREATE DATABASE luandry_schema_21092018 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
 '   DROP DATABASE luandry_schema_21092018;
             postgres    false                        2615    20515    auth_public    SCHEMA        CREATE SCHEMA auth_public;
    DROP SCHEMA auth_public;
             postgres    false            2           0    0    SCHEMA auth_public    ACL     n   GRANT USAGE ON SCHEMA auth_public TO auth_anonymous;
GRANT USAGE ON SCHEMA auth_public TO auth_authenticated;
                  postgres    false    7                        2615    21085    postgraphile_watch    SCHEMA     "   CREATE SCHEMA postgraphile_watch;
     DROP SCHEMA postgraphile_watch;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            3           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    5            4           0    0    SCHEMA public    ACL     d   GRANT USAGE ON SCHEMA public TO auth_authenticated;
GRANT USAGE ON SCHEMA public TO auth_anonymous;
                  postgres    false    5                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            5           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    20344    citext 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
    DROP EXTENSION citext;
                  false    5            6           0    0    EXTENSION citext    COMMENT     S   COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';
                       false    2                        3079    20307    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    5            7           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    3            z           1247    20532    jwt    TYPE     R   CREATE TYPE auth_public.jwt AS (
	role text,
	user_id integer,
	user_type text
);
    DROP TYPE auth_public.jwt;
       auth_public       postgres    false    7                       1255    20541    authenticate(text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.authenticate(email text, password text, user_type text) RETURNS auth_public.jwt
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
       auth_public       postgres    false    7    890    1            8           0    0 @   FUNCTION authenticate(email text, password text, user_type text)    ACL     �   GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public.authenticate(email text, password text, user_type text) TO auth_authenticated;
            auth_public       postgres    false    276            	           1259    20518    user    TABLE     U  CREATE TABLE auth_public."user" (
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
            auth_public       postgres    false    265            P           1255    20542    current_user()    FUNCTION     �   CREATE FUNCTION auth_public."current_user"() RETURNS auth_public."user"
    LANGUAGE sql STABLE
    AS $$ 
  SELECT * 
  FROM auth_public.user 
  WHERE id = auth_public.current_user_id()
$$;
 ,   DROP FUNCTION auth_public."current_user"();
       auth_public       postgres    false    7    265            :           0    0    FUNCTION "current_user"()    ACL     �   GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_anonymous;
GRANT ALL ON FUNCTION auth_public."current_user"() TO auth_authenticated;
            auth_public       postgres    false    336            "           1255    20533    current_user_id()    FUNCTION     �   CREATE FUNCTION auth_public.current_user_id() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  SELECT current_setting('jwt.claims.user_id', true)::integer;
$$;
 -   DROP FUNCTION auth_public.current_user_id();
       auth_public       postgres    false    7            C           1255    20537 +   register_user(text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) RETURNS auth_public."user"
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
       auth_public       postgres    false    265    7    1            ;           0    0 b   FUNCTION register_user(first_name text, last_name text, email text, user_type text, password text)    ACL     �   GRANT ALL ON FUNCTION auth_public.register_user(first_name text, last_name text, email text, user_type text, password text) TO auth_anonymous;
            auth_public       postgres    false    323            h           1255    21086    notify_watchers_ddl()    FUNCTION     �  CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
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
       postgraphile_watch       postgres    false    11    1            H           1255    21087    notify_watchers_drop()    FUNCTION     _  CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
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
       postgraphile_watch       postgres    false    11    1                       1259    20516    user_id_seq    SEQUENCE     �   CREATE SEQUENCE auth_public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth_public.user_id_seq;
       auth_public       postgres    false    265    7            <           0    0    user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE auth_public.user_id_seq OWNED BY auth_public."user".id;
            auth_public       postgres    false    264            �            1259    19686    bill_seq    SEQUENCE     q   CREATE SEQUENCE public.bill_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.bill_seq;
       public       postgres    false    5            �            1259    19688    bill    TABLE     �  CREATE TABLE public.bill (
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
            public       postgres    false    201            �            1259    19692    bill_detail_seq    SEQUENCE     x   CREATE SEQUENCE public.bill_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.bill_detail_seq;
       public       postgres    false    5            �            1259    19694    bill_detail    TABLE     2  CREATE TABLE public.bill_detail (
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
            public       postgres    false    203            �            1259    19701 
   branch_seq    SEQUENCE     s   CREATE SEQUENCE public.branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.branch_seq;
       public       postgres    false    5            �            1259    19703    branch    TABLE     �  CREATE TABLE public.branch (
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
            public       postgres    false    205            �            1259    19710 	   color_seq    SEQUENCE     r   CREATE SEQUENCE public.color_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.color_seq;
       public       postgres    false    5            �            1259    19712    color    TABLE     l  CREATE TABLE public.color (
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
            public       postgres    false    207            �            1259    19719    color_group_seq    SEQUENCE     x   CREATE SEQUENCE public.color_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.color_group_seq;
       public       postgres    false    5            �            1259    19721    color_group    TABLE     \  CREATE TABLE public.color_group (
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
            public       postgres    false    209            �            1259    19728    customer_seq    SEQUENCE     u   CREATE SEQUENCE public.customer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.customer_seq;
       public       postgres    false    5            �            1259    19730    customer    TABLE     �  CREATE TABLE public.customer (
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
       public         postgres    false    210    5            B           0    0    TABLE customer    ACL     �   GRANT DELETE ON TABLE public.customer TO auth_authenticated;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.customer TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    211            �            1259    19737    customer_order_seq    SEQUENCE     {   CREATE SEQUENCE public.customer_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.customer_order_seq;
       public       postgres    false    5            �            1259    19739    customer_order    TABLE     �  CREATE TABLE public.customer_order (
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
            public       postgres    false    213            �            1259    19743    dry_seq    SEQUENCE     p   CREATE SEQUENCE public.dry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.dry_seq;
       public       postgres    false    5            �            1259    19745    dry    TABLE     b  CREATE TABLE public.dry (
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
            public       postgres    false    215            �            1259    19749 	   dryer_seq    SEQUENCE     r   CREATE SEQUENCE public.dryer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.dryer_seq;
       public       postgres    false    5            �            1259    19751    dryer    TABLE     �  CREATE TABLE public.dryer (
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
            public       postgres    false    217            �            1259    19758 	   label_seq    SEQUENCE     r   CREATE SEQUENCE public.label_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.label_seq;
       public       postgres    false    5            �            1259    19760    label    TABLE     J  CREATE TABLE public.label (
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
            public       postgres    false    219            �            1259    19767    material_seq    SEQUENCE     u   CREATE SEQUENCE public.material_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.material_seq;
       public       postgres    false    5            �            1259    19769    material    TABLE     S  CREATE TABLE public.material (
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
            public       postgres    false    221            �            1259    19776    order_detail_seq    SEQUENCE     y   CREATE SEQUENCE public.order_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.order_detail_seq;
       public       postgres    false    5            �            1259    19778    order_detail    TABLE     5  CREATE TABLE public.order_detail (
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
            public       postgres    false    223            �            1259    19785    payment_seq    SEQUENCE     t   CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.payment_seq;
       public       postgres    false    5            �            1259    19787    payment    TABLE     P  CREATE TABLE public.payment (
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
            public       postgres    false    225                       1259    20954    post    TABLE     t   CREATE TABLE public.post (
    id integer NOT NULL,
    headline text,
    body text,
    header_image_file text
);
    DROP TABLE public.post;
       public         postgres    false    5            J           0    0 
   TABLE post    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.post TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    268                       1259    20952    post_id_seq    SEQUENCE     �   CREATE SEQUENCE public.post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.post_id_seq;
       public       postgres    false    5    268            K           0    0    post_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.post_id_seq OWNED BY public.post.id;
            public       postgres    false    267            L           0    0    SEQUENCE post_id_seq    ACL     @   GRANT ALL ON SEQUENCE public.post_id_seq TO auth_authenticated;
            public       postgres    false    267            �            1259    19794    product_seq    SEQUENCE     t   CREATE SEQUENCE public.product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.product_seq;
       public       postgres    false    5            �            1259    19796    product    TABLE     �  CREATE TABLE public.product (
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
       public         postgres    false    226    5            M           0    0    TABLE product    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    227            �            1259    19803    product_type_seq    SEQUENCE     y   CREATE SEQUENCE public.product_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.product_type_seq;
       public       postgres    false    5            �            1259    19805    product_type    TABLE     _  CREATE TABLE public.product_type (
    id numeric(19,0) DEFAULT nextval('public.product_type_seq'::regclass) NOT NULL,
    product_type_name character varying(2000),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone
);
     DROP TABLE public.product_type;
       public         postgres    false    228    5            N           0    0    TABLE product_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.product_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    229            �            1259    19812    promotion_seq    SEQUENCE     v   CREATE SEQUENCE public.promotion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.promotion_seq;
       public       postgres    false    5            �            1259    19814 	   promotion    TABLE     �  CREATE TABLE public.promotion (
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
       public         postgres    false    230    5            O           0    0    TABLE promotion    ACL     q   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    231            �            1259    19821    promotion_branch_seq    SEQUENCE     }   CREATE SEQUENCE public.promotion_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.promotion_branch_seq;
       public       postgres    false    5            �            1259    19823    promotion_branch    TABLE     u  CREATE TABLE public.promotion_branch (
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
       public         postgres    false    232    5            P           0    0    TABLE promotion_branch    ACL     x   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.promotion_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    233            �            1259    19827    receipt_seq    SEQUENCE     t   CREATE SEQUENCE public.receipt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.receipt_seq;
       public       postgres    false    5            �            1259    19829    receipt    TABLE     �  CREATE TABLE public.receipt (
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
       public         postgres    false    234    5            Q           0    0    TABLE receipt    ACL     o   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    235            �            1259    19833    receipt_detail    TABLE       CREATE TABLE public.receipt_detail (
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
            public       postgres    false    236            �            1259    19837    receipt_detail_seq    SEQUENCE     {   CREATE SEQUENCE public.receipt_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.receipt_detail_seq;
       public       postgres    false    5            �            1259    19839    receipt_wash_bag_seq    SEQUENCE     }   CREATE SEQUENCE public.receipt_wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.receipt_wash_bag_seq;
       public       postgres    false    5            �            1259    19841    receipt_wash_bag    TABLE     u  CREATE TABLE public.receipt_wash_bag (
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
       public         postgres    false    238    5            S           0    0    TABLE receipt_wash_bag    ACL     x   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.receipt_wash_bag TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    239            �            1259    19845    service_type_seq    SEQUENCE     y   CREATE SEQUENCE public.service_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.service_type_seq;
       public       postgres    false    5            �            1259    19847    service_type    TABLE     �  CREATE TABLE public.service_type (
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
       public         postgres    false    240    5            T           0    0    TABLE service_type    ACL     t   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    241            �            1259    19854    service_type_branch_seq    SEQUENCE     �   CREATE SEQUENCE public.service_type_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.service_type_branch_seq;
       public       postgres    false    5            �            1259    19856    service_type_branch    TABLE     u  CREATE TABLE public.service_type_branch (
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
       public         postgres    false    242    5            U           0    0    TABLE service_type_branch    ACL     {   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.service_type_branch TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    243            �            1259    19860 	   staff_seq    SEQUENCE     r   CREATE SEQUENCE public.staff_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.staff_seq;
       public       postgres    false    5            �            1259    19862    staff    TABLE     �  CREATE TABLE public.staff (
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
       public         postgres    false    244    5            V           0    0    TABLE staff    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    245            �            1259    19869    staff_type_seq    SEQUENCE     w   CREATE SEQUENCE public.staff_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.staff_type_seq;
       public       postgres    false    5            �            1259    19871 
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
       public         postgres    false    246    5            W           0    0    TABLE staff_type    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.staff_type TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    247            �            1259    19878 	   store_seq    SEQUENCE     r   CREATE SEQUENCE public.store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.store_seq;
       public       postgres    false    5            �            1259    19880    store    TABLE     �  CREATE TABLE public.store (
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
       public         postgres    false    248    5            X           0    0    TABLE store    ACL     m   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.store TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    249            �            1259    19887    time_schedule_seq    SEQUENCE     z   CREATE SEQUENCE public.time_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.time_schedule_seq;
       public       postgres    false    5            �            1259    19889    time_schedule    TABLE     �  CREATE TABLE public.time_schedule (
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
       public         postgres    false    250    5            Y           0    0    TABLE time_schedule    ACL     u   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.time_schedule TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    251            �            1259    19893    unit_seq    SEQUENCE     q   CREATE SEQUENCE public.unit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.unit_seq;
       public       postgres    false    5            �            1259    19895    unit    TABLE     a  CREATE TABLE public.unit (
    id numeric(19,0) DEFAULT nextval('public.unit_seq'::regclass) NOT NULL,
    unit_name character varying(200) NOT NULL,
    status character varying(200),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone
);
    DROP TABLE public.unit;
       public         postgres    false    252    5            Z           0    0 
   TABLE unit    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    253            �            1259    19899    unit_price_seq    SEQUENCE     w   CREATE SEQUENCE public.unit_price_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.unit_price_seq;
       public       postgres    false    5            �            1259    19901 
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
       public         postgres    false    254    5            [           0    0    TABLE unit_price    ACL     r   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.unit_price TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    255                        1259    19905    wash_seq    SEQUENCE     q   CREATE SEQUENCE public.wash_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.wash_seq;
       public       postgres    false    5                       1259    19907    wash    TABLE     e  CREATE TABLE public.wash (
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
       public         postgres    false    256    5            \           0    0 
   TABLE wash    ACL     l   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    257                       1259    19911    wash_bag_seq    SEQUENCE     u   CREATE SEQUENCE public.wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.wash_bag_seq;
       public       postgres    false    5                       1259    19913    wash_bag    TABLE     R  CREATE TABLE public.wash_bag (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_seq'::regclass) NOT NULL,
    wash_bag_name character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.wash_bag;
       public         postgres    false    258    5            ]           0    0    TABLE wash_bag    ACL     p   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    259                       1259    19917    wash_bag_detail_seq    SEQUENCE     |   CREATE SEQUENCE public.wash_bag_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.wash_bag_detail_seq;
       public       postgres    false    5                       1259    19919    wash_bag_detail    TABLE       CREATE TABLE public.wash_bag_detail (
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
       public         postgres    false    260    5            ^           0    0    TABLE wash_bag_detail    ACL     w   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.wash_bag_detail TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    261                       1259    19923    washing_machine_seq    SEQUENCE     |   CREATE SEQUENCE public.washing_machine_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.washing_machine_seq;
       public       postgres    false    5                       1259    19925    washing_machine    TABLE     �  CREATE TABLE public.washing_machine (
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
       public         postgres    false    262    5            _           0    0    TABLE washing_machine    ACL     w   GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.washing_machine TO auth_authenticated WITH GRANT OPTION;
            public       postgres    false    263            �           2604    20521    user id    DEFAULT     n   ALTER TABLE ONLY auth_public."user" ALTER COLUMN id SET DEFAULT nextval('auth_public.user_id_seq'::regclass);
 =   ALTER TABLE auth_public."user" ALTER COLUMN id DROP DEFAULT;
       auth_public       postgres    false    264    265    265            �           2604    20957    post id    DEFAULT     b   ALTER TABLE ONLY public.post ALTER COLUMN id SET DEFAULT nextval('public.post_id_seq'::regclass);
 6   ALTER TABLE public.post ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    267    268    268            )          0    20518    user 
   TABLE DATA               W   COPY auth_public."user" (id, first_name, last_name, created_at, user_type) FROM stdin;
    auth_public       postgres    false    265   �      �          0    19688    bill 
   TABLE DATA               �   COPY public.bill (id, receipt_id, create_id, shipper_id, payment_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    201   ��      �          0    19694    bill_detail 
   TABLE DATA               �   COPY public.bill_detail (id, bill_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    203   ֍      �          0    19703    branch 
   TABLE DATA               �   COPY public.branch (id, branch_name, store_id, address, create_by, update_by, create_date, update_date, status, branch_avatar) FROM stdin;
    public       postgres    false    205   �      �          0    19712    color 
   TABLE DATA               w   COPY public.color (id, color_name, color_group_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    207   �      �          0    19721    color_group 
   TABLE DATA               s   COPY public.color_group (id, color_group_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    209   -�      �          0    19730    customer 
   TABLE DATA               �   COPY public.customer (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, customer_avatar) FROM stdin;
    public       postgres    false    211   J�      �          0    19739    customer_order 
   TABLE DATA               �   COPY public.customer_order (id, customer_id, branch_id, pick_up_date, pick_up_time_id, delivery_date, delivery_time_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    213   l�      �          0    19745    dry 
   TABLE DATA               y   COPY public.dry (id, wash_bag_id, drying_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    215   ��      �          0    19751    dryer 
   TABLE DATA               �   COPY public.dryer (id, branch_id, bought_date, buyer, create_by, update_by, create_date, update_date, status, dryer_name) FROM stdin;
    public       postgres    false    217   ��      �          0    19760    label 
   TABLE DATA               g   COPY public.label (id, label_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    219   Ø      �          0    19769    material 
   TABLE DATA               m   COPY public.material (id, material_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    221   �      �          0    19778    order_detail 
   TABLE DATA               �   COPY public.order_detail (id, order_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    223   %�                0    19787    payment 
   TABLE DATA               k   COPY public.payment (id, payment_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    225   B�      +          0    20954    post 
   TABLE DATA               E   COPY public.post (id, headline, body, header_image_file) FROM stdin;
    public       postgres    false    268   _�                0    19796    product 
   TABLE DATA               �   COPY public.product (id, product_name, create_by, update_by, create_date, update_date, status, product_image, short_desc, producy_type_id, product_avatar) FROM stdin;
    public       postgres    false    227   �                0    19805    product_type 
   TABLE DATA               u   COPY public.product_type (id, product_type_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    229   *�                0    19814 	   promotion 
   TABLE DATA               �   COPY public.promotion (id, promotion_name, sale, date_start, date_end, promotion_code, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    231   X�      	          0    19823    promotion_branch 
   TABLE DATA                  COPY public.promotion_branch (id, promotion_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    233   u�                0    19829    receipt 
   TABLE DATA               �   COPY public.receipt (id, order_id, pick_up_time, delivery_time, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    235   ��                0    19833    receipt_detail 
   TABLE DATA               �   COPY public.receipt_detail (id, receipt_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    236   ��                0    19841    receipt_wash_bag 
   TABLE DATA                  COPY public.receipt_wash_bag (id, wash_bag_id, receipt_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    239   ̛                0    19847    service_type 
   TABLE DATA               �   COPY public.service_type (id, service_type_name, service_type_desc, status, create_by, update_by, create_date, update_date, service_type_avatar) FROM stdin;
    public       postgres    false    241   �                0    19856    service_type_branch 
   TABLE DATA               �   COPY public.service_type_branch (id, service_type_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    243   ��                0    19862    staff 
   TABLE DATA               �   COPY public.staff (id, full_name, email, username, password, gender, address, phone, status, hash_codes, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, staff_type_id, branch_id, staff_avatar) FROM stdin;
    public       postgres    false    245   ̜                0    19871 
   staff_type 
   TABLE DATA               q   COPY public.staff_type (id, staff_type_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    247   J�                0    19880    store 
   TABLE DATA               ~   COPY public.store (id, store_name, address, create_by, update_by, create_date, update_date, status, store_avatar) FROM stdin;
    public       postgres    false    249   g�                0    19889    time_schedule 
   TABLE DATA               �   COPY public.time_schedule (id, time_schedule_no, time_start, time_end, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    251   ��                0    19895    unit 
   TABLE DATA               e   COPY public.unit (id, unit_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    253   ��                0    19901 
   unit_price 
   TABLE DATA               �   COPY public.unit_price (id, product_id, service_type_id, material_id, unit_id, apply_date, price, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    255   �      !          0    19907    wash 
   TABLE DATA               {   COPY public.wash (id, wash_bag_id, washing_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    257   �      #          0    19913    wash_bag 
   TABLE DATA               m   COPY public.wash_bag (id, wash_bag_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    259   !�      %          0    19919    wash_bag_detail 
   TABLE DATA               �   COPY public.wash_bag_detail (id, wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    261   >�      '          0    19925    washing_machine 
   TABLE DATA               �   COPY public.washing_machine (id, branch_id, bought_date, buyer, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    263   [�      `           0    0    user_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth_public.user_id_seq', 48, true);
            auth_public       postgres    false    264            a           0    0    bill_detail_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.bill_detail_seq', 1, false);
            public       postgres    false    202            b           0    0    bill_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.bill_seq', 1, false);
            public       postgres    false    200            c           0    0 
   branch_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.branch_seq', 1, false);
            public       postgres    false    204            d           0    0    color_group_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.color_group_seq', 1, false);
            public       postgres    false    208            e           0    0 	   color_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.color_seq', 1, false);
            public       postgres    false    206            f           0    0    customer_order_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.customer_order_seq', 1, false);
            public       postgres    false    212            g           0    0    customer_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.customer_seq', 3, true);
            public       postgres    false    210            h           0    0    dry_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.dry_seq', 1, false);
            public       postgres    false    214            i           0    0 	   dryer_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.dryer_seq', 1, false);
            public       postgres    false    216            j           0    0 	   label_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.label_seq', 1, true);
            public       postgres    false    218            k           0    0    material_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.material_seq', 1, true);
            public       postgres    false    220            l           0    0    order_detail_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.order_detail_seq', 1, false);
            public       postgres    false    222            m           0    0    payment_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.payment_seq', 1, false);
            public       postgres    false    224            n           0    0    post_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.post_id_seq', 14, true);
            public       postgres    false    267            o           0    0    product_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.product_seq', 1, true);
            public       postgres    false    226            p           0    0    product_type_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.product_type_seq', 1, true);
            public       postgres    false    228            q           0    0    promotion_branch_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.promotion_branch_seq', 1, false);
            public       postgres    false    232            r           0    0    promotion_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.promotion_seq', 1, false);
            public       postgres    false    230            s           0    0    receipt_detail_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.receipt_detail_seq', 1, false);
            public       postgres    false    237            t           0    0    receipt_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.receipt_seq', 1, false);
            public       postgres    false    234            u           0    0    receipt_wash_bag_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.receipt_wash_bag_seq', 1, false);
            public       postgres    false    238            v           0    0    service_type_branch_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.service_type_branch_seq', 1, false);
            public       postgres    false    242            w           0    0    service_type_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.service_type_seq', 1, true);
            public       postgres    false    240            x           0    0 	   staff_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.staff_seq', 1, false);
            public       postgres    false    244            y           0    0    staff_type_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.staff_type_seq', 1, false);
            public       postgres    false    246            z           0    0 	   store_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.store_seq', 1, false);
            public       postgres    false    248            {           0    0    time_schedule_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.time_schedule_seq', 1, false);
            public       postgres    false    250            |           0    0    unit_price_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.unit_price_seq', 1, false);
            public       postgres    false    254            }           0    0    unit_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.unit_seq', 1, true);
            public       postgres    false    252            ~           0    0    wash_bag_detail_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.wash_bag_detail_seq', 1, false);
            public       postgres    false    260                       0    0    wash_bag_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.wash_bag_seq', 1, false);
            public       postgres    false    258            �           0    0    wash_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.wash_seq', 1, false);
            public       postgres    false    256            �           0    0    washing_machine_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.washing_machine_seq', 1, false);
            public       postgres    false    262            -           2606    20529    user user_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY auth_public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 ?   ALTER TABLE ONLY auth_public."user" DROP CONSTRAINT user_pkey;
       auth_public         postgres    false    265            �           2606    19930    bill_detail bill_detail_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT bill_detail_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT bill_detail_pkey;
       public         postgres    false    203            �           2606    19932    bill bill_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.bill DROP CONSTRAINT bill_pkey;
       public         postgres    false    201            �           2606    19934    branch branch_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_pkey;
       public         postgres    false    205            �           2606    19936    color_group color_group_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.color_group
    ADD CONSTRAINT color_group_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.color_group DROP CONSTRAINT color_group_pkey;
       public         postgres    false    209            �           2606    19938    color color_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.color DROP CONSTRAINT color_pkey;
       public         postgres    false    207            �           2606    19940 "   customer_order customer_order_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT customer_order_pkey;
       public         postgres    false    213            �           2606    19942    customer customer_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_pkey;
       public         postgres    false    211            �           2606    19944    dry dry_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT dry_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.dry DROP CONSTRAINT dry_pkey;
       public         postgres    false    215            �           2606    19946    dryer dryer_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT dryer_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.dryer DROP CONSTRAINT dryer_pkey;
       public         postgres    false    217                       2606    19948    label label_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.label DROP CONSTRAINT label_pkey;
       public         postgres    false    219                       2606    19950    material material_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.material DROP CONSTRAINT material_pkey;
       public         postgres    false    221                       2606    19952    order_detail order_detail_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT order_detail_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT order_detail_pkey;
       public         postgres    false    223                       2606    19954    payment payment_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.payment DROP CONSTRAINT payment_pkey;
       public         postgres    false    225            /           2606    20962    post post_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.post DROP CONSTRAINT post_pkey;
       public         postgres    false    268            	           2606    19956    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public         postgres    false    227                       2606    19958    product_type product_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_type DROP CONSTRAINT product_type_pkey;
       public         postgres    false    229                       2606    20257 &   promotion_branch promotion_branch_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT promotion_branch_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT promotion_branch_pkey;
       public         postgres    false    233                       2606    19960    promotion promotion_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public         postgres    false    231                       2606    19962 "   receipt_detail receipt_detail_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT receipt_detail_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT receipt_detail_pkey;
       public         postgres    false    236                       2606    19964    receipt receipt_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.receipt DROP CONSTRAINT receipt_pkey;
       public         postgres    false    235                       2606    19966 &   receipt_wash_bag receipt_wash_bag_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT receipt_wash_bag_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT receipt_wash_bag_pkey;
       public         postgres    false    239                       2606    19968    service_type service_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_pkey;
       public         postgres    false    241                       2606    19970    staff staff_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public         postgres    false    245                       2606    19972    staff_type staff_type_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.staff_type
    ADD CONSTRAINT staff_type_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.staff_type DROP CONSTRAINT staff_type_pkey;
       public         postgres    false    247                       2606    19974    store store_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.store DROP CONSTRAINT store_pkey;
       public         postgres    false    249                       2606    19976     time_schedule time_schedule_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.time_schedule
    ADD CONSTRAINT time_schedule_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.time_schedule DROP CONSTRAINT time_schedule_pkey;
       public         postgres    false    251            !           2606    19978    unit unit_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.unit DROP CONSTRAINT unit_pkey;
       public         postgres    false    253            #           2606    19980    unit_price unit_price_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT unit_price_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT unit_price_pkey;
       public         postgres    false    255            )           2606    19982 $   wash_bag_detail wash_bag_detail_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT wash_bag_detail_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT wash_bag_detail_pkey;
       public         postgres    false    261            '           2606    19984    wash_bag wash_bag_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.wash_bag
    ADD CONSTRAINT wash_bag_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.wash_bag DROP CONSTRAINT wash_bag_pkey;
       public         postgres    false    259            %           2606    19986    wash wash_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT wash_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.wash DROP CONSTRAINT wash_pkey;
       public         postgres    false    257            +           2606    19988 $   washing_machine washing_machine_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.washing_machine
    ADD CONSTRAINT washing_machine_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.washing_machine DROP CONSTRAINT washing_machine_pkey;
       public         postgres    false    263            <           2606    20983     branch branch_branch_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_avatar_fkey FOREIGN KEY (branch_avatar) REFERENCES public.post(id);
 J   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_branch_avatar_fkey;
       public       postgres    false    205    268    3119            >           2606    20963 &   customer customer_customer_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_customer_avatar_fkey FOREIGN KEY (customer_avatar) REFERENCES public.post(id);
 P   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_customer_avatar_fkey;
       public       postgres    false    268    3119    211            0           2606    19989    bill fk_bill_create_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_create_id FOREIGN KEY (create_id) REFERENCES public.staff(id);
 @   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_create_id;
       public       postgres    false    245    3097    201            4           2606    19994 "   bill_detail fk_bill_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_bill_id FOREIGN KEY (bill_id) REFERENCES public.bill(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_bill_id;
       public       postgres    false    203    201    3055            5           2606    19999 #   bill_detail fk_bill_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_color_id;
       public       postgres    false    3061    207    203            6           2606    20004 #   bill_detail fk_bill_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_label_id;
       public       postgres    false    219    203    3073            7           2606    20009 &   bill_detail fk_bill_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 P   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_material_id;
       public       postgres    false    221    3075    203            8           2606    20014 %   bill_detail fk_bill_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 O   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_product_id;
       public       postgres    false    227    203    3081            9           2606    20019 *   bill_detail fk_bill_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 T   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_service_type_id;
       public       postgres    false    203    241    3095            :           2606    20024 "   bill_detail fk_bill_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_id;
       public       postgres    false    203    3105    253            1           2606    20029    bill fk_bill_payment_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_payment_id FOREIGN KEY (payment_id) REFERENCES public.payment(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_payment_id;
       public       postgres    false    225    3079    201            2           2606    20034    bill fk_bill_receipt_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_receipt_id;
       public       postgres    false    3089    235    201            3           2606    20039    bill fk_bill_shipper_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_shipper_id FOREIGN KEY (shipper_id) REFERENCES public.staff(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_shipper_id;
       public       postgres    false    245    201    3097            [           2606    20044    staff fk_branch_id    FK CONSTRAINT     t   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 <   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_branch_id;
       public       postgres    false    245    205    3059            ;           2606    20049    branch fk_branch_store_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT fk_branch_store_id FOREIGN KEY (store_id) REFERENCES public.store(id);
 C   ALTER TABLE ONLY public.branch DROP CONSTRAINT fk_branch_store_id;
       public       postgres    false    3101    205    249            =           2606    20054    color fk_color_color_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.color
    ADD CONSTRAINT fk_color_color_group_id FOREIGN KEY (color_group_id) REFERENCES public.color_group(id);
 G   ALTER TABLE ONLY public.color DROP CONSTRAINT fk_color_color_group_id;
       public       postgres    false    209    207    3063            ?           2606    20059 *   customer_order fk_customer_order_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 T   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_branch_id;
       public       postgres    false    205    3059    213            @           2606    20064 ,   customer_order fk_customer_order_customer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 V   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_customer_id;
       public       postgres    false    3065    211    213            A           2606    20069 1   customer_order fk_customer_order_delivery_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_delivery_time_id FOREIGN KEY (delivery_time_id) REFERENCES public.time_schedule(id);
 [   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_delivery_time_id;
       public       postgres    false    251    3103    213            B           2606    20074 0   customer_order fk_customer_order_pick_up_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_pick_up_time_id FOREIGN KEY (pick_up_time_id) REFERENCES public.time_schedule(id);
 Z   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_pick_up_time_id;
       public       postgres    false    3103    251    213            C           2606    20079     dry fk_dry_dry_drying_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_dry_drying_machine_id FOREIGN KEY (drying_machine_id) REFERENCES public.dryer(id);
 J   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_dry_drying_machine_id;
       public       postgres    false    3071    215    217            D           2606    20084    dry fk_dry_wash_bag_id    FK CONSTRAINT     |   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 @   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_wash_bag_id;
       public       postgres    false    3111    259    215            E           2606    20089    dryer fk_dryer_branch_id    FK CONSTRAINT     z   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT fk_dryer_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 B   ALTER TABLE ONLY public.dryer DROP CONSTRAINT fk_dryer_branch_id;
       public       postgres    false    3059    205    217            F           2606    20094 %   order_detail fk_order_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_label_id;
       public       postgres    false    219    3073    223            G           2606    20099 %   order_detail fk_order_detail_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_order_id;
       public       postgres    false    3067    213    223            H           2606    20104 ,   order_detail fk_order_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 V   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_service_type_id;
       public       postgres    false    3095    223    241            I           2606    20109 $   order_detail fk_order_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 N   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_id;
       public       postgres    false    253    223    3105            J           2606    20114 "   product fk_product_product_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT fk_product_product_type_id FOREIGN KEY (producy_type_id) REFERENCES public.product_type(id);
 L   ALTER TABLE ONLY public.product DROP CONSTRAINT fk_product_product_type_id;
       public       postgres    false    3083    227    229            L           2606    20119 .   promotion_branch fk_promotion_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 X   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_branch_id;
       public       postgres    false    233    3059    205            M           2606    20124 1   promotion_branch fk_promotion_branch_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 [   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_promotion_id;
       public       postgres    false    3085    233    231            O           2606    20129 (   receipt_detail fk_receipt_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_bill_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_bill_id;
       public       postgres    false    235    3089    236            P           2606    20134 )   receipt_detail fk_receipt_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_color_id;
       public       postgres    false    207    236    3061            Q           2606    20139 )   receipt_detail fk_receipt_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_label_id;
       public       postgres    false    236    219    3073            R           2606    20144 ,   receipt_detail fk_receipt_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 V   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_material_id;
       public       postgres    false    236    221    3075            S           2606    20149 +   receipt_detail fk_receipt_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 U   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_product_id;
       public       postgres    false    227    236    3081            T           2606    20154 0   receipt_detail fk_receipt_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 Z   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_service_type_id;
       public       postgres    false    236    241    3095            U           2606    20159 (   receipt_detail fk_receipt_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_id;
       public       postgres    false    236    3105    253            N           2606    20164    receipt fk_receipt_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 E   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_order_id;
       public       postgres    false    213    3067    235            V           2606    20169 /   receipt_wash_bag fk_receipt_wash_bag_receipt_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 Y   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_receipt_id;
       public       postgres    false    239    235    3089            W           2606    20174 0   receipt_wash_bag fk_receipt_wash_bag_wash_bag_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 Z   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_wash_bag_id;
       public       postgres    false    239    259    3111            Y           2606    20179 4   service_type_branch fk_service_type_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 ^   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_branch_id;
       public       postgres    false    243    205    3059            Z           2606    20184 :   service_type_branch fk_service_type_branch_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 d   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_service_type_id;
       public       postgres    false    243    241    3095            \           2606    20189    staff fk_staff_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_type_id FOREIGN KEY (staff_type_id) REFERENCES public.staff_type(id);
 @   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_staff_type_id;
       public       postgres    false    245    247    3099            _           2606    20194 #   unit_price fk_unit_price_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 M   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_product_id;
       public       postgres    false    255    227    3081            `           2606    20199 (   unit_price fk_unit_price_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 R   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_service_type_id;
       public       postgres    false    3095    255    241            a           2606    20204     unit_price fk_unit_price_unit_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 J   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_unit_id;
       public       postgres    false    3105    255    253            d           2606    20209 *   wash_bag_detail fk_wash_bag_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_bill_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_bill_id;
       public       postgres    false    261    259    3111            e           2606    20214 +   wash_bag_detail fk_wash_bag_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_color_id;
       public       postgres    false    207    261    3061            f           2606    20219 +   wash_bag_detail fk_wash_bag_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_label_id;
       public       postgres    false    261    219    3073            g           2606    20224 .   wash_bag_detail fk_wash_bag_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 X   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_material_id;
       public       postgres    false    221    3075    261            h           2606    20229 -   wash_bag_detail fk_wash_bag_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_product_id;
       public       postgres    false    227    3081    261            i           2606    20234 2   wash_bag_detail fk_wash_bag_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 \   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_service_type_id;
       public       postgres    false    241    3095    261            j           2606    20239 *   wash_bag_detail fk_wash_bag_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_unit_id;
       public       postgres    false    253    261    3105            b           2606    20244    wash fk_wash_wash_bag_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 B   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_bag_id;
       public       postgres    false    257    259    3111            c           2606    20249 $   wash fk_wash_wash_washing_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_washing_machine_id FOREIGN KEY (washing_machine_id) REFERENCES public.washing_machine(id);
 N   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_washing_machine_id;
       public       postgres    false    263    257    3115            K           2606    20973 #   product product_product_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_product_avatar_fkey FOREIGN KEY (product_avatar) REFERENCES public.post(id);
 M   ALTER TABLE ONLY public.product DROP CONSTRAINT product_product_avatar_fkey;
       public       postgres    false    3119    268    227            X           2606    20978 2   service_type service_type_service_type_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_service_type_avatar_fkey FOREIGN KEY (service_type_avatar) REFERENCES public.post(id);
 \   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_service_type_avatar_fkey;
       public       postgres    false    268    241    3119            ]           2606    20968    staff staff_staff_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_staff_avatar_fkey FOREIGN KEY (staff_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_staff_avatar_fkey;
       public       postgres    false    245    3119    268            ^           2606    20988    store store_store_avatar_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_store_avatar_fkey FOREIGN KEY (store_avatar) REFERENCES public.post(id);
 G   ALTER TABLE ONLY public.store DROP CONSTRAINT store_store_avatar_fkey;
       public       postgres    false    249    3119    268            �           3466    21088    postgraphile_watch_ddl    EVENT TRIGGER       CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_ddl();
 +   DROP EVENT TRIGGER postgraphile_watch_ddl;
             postgres    false    360            �           3466    21089    postgraphile_watch_drop    EVENT TRIGGER     y   CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_drop();
 ,   DROP EVENT TRIGGER postgraphile_watch_drop;
             postgres    false    328            �           3256    20536    user delete_user    POLICY        CREATE POLICY delete_user ON auth_public."user" FOR DELETE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY delete_user ON auth_public."user";
       auth_public       postgres    false    265    290    265            �           3256    20534    user select_user    POLICY     I   CREATE POLICY select_user ON auth_public."user" FOR SELECT USING (true);
 /   DROP POLICY select_user ON auth_public."user";
       auth_public       postgres    false    265            �           3256    20535    user update_user    POLICY        CREATE POLICY update_user ON auth_public."user" FOR UPDATE TO auth_authenticated USING ((id = auth_public.current_user_id()));
 /   DROP POLICY update_user ON auth_public."user";
       auth_public       postgres    false    265    290    265            �           0    20518    user    ROW SECURITY     9   ALTER TABLE auth_public."user" ENABLE ROW LEVEL SECURITY;            auth_public       postgres    false            )   �  x���Kn�1F����h䷝l�F��P��`@��������,�(��c;x�p�����r��t�|"���zKt���[�pT9}{������������3�9iM� R8��Ŭ����?9n��U}������������o��4�h�q���=<\	_܏Am�E�x���@�HԢ�a:@u�M� �)�@�Ry?���`����0�r�4f�����s���-���PR���E�`#�ge�ӻ�孇�O�b��� ږ���ĉZ����32&����imv�V��]K5��7���cK.�8 �F�\q̝�f�d��P(O	�Ҍ�Ҽb�L���#!o�U��D9iFj)�Ae����#�z��j�wb�.a�eb:�1��H*�����Ġ�y=9� �8Q;1� �ӉM5�"�ƌ��}�S�����g��
��R����t� H�q��ʍ+��(�,����WJ�LC�}��ʍNIO#���g��ʍw�v�k
5�-^�q�X����u2R+7ީ|W�:�E�+7�T%9I9Ʃ!+7:�ˤ/�B�"c�ʍw�2[�ک�G+s��]���SC����:��[HvjhV��gS���N���k��d����(Ti:k�F_��������ƌ���R�sQԗr>�� ��=      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   
  x���Iϛhֆ�ɯȢ�]�yȪl0lf���y�g~��8����9%�[��d]�s���>�S�t	�8I�?�ĭ�����o�����ec# {�Ύ��J��^h��t�p���I{�9kl�G�X]�������=��&	!�v.J�<���y����<���)o!Ƿ���\0ں�e#�.]�'��ى]n��x��f߉
�!n5s��x�<��*T[Ή�p��F�bc��Xr�\��G��0�*{��X�=��bk��j{�J'��#���;��/7�߮����nZ ~]~�{��E��Qg�ZܦY��"h�6lq��G�wfLAA��K��]�d��؃PI�~�� �0��c���/r��ԚtQ+��WG4�q�U�}��*|�o��v��!��㪾W�D�6�`u7��r���uh1v���vW�X��g�8�C�)�����S���П��-D.2]��&p��>Bv��U�2�p��6V��hcd=;g�._*z7�	���Ѩ�z޿�5�z˲^P�F����x�m��s�)=#F`_�|� `7���ŷ�^�.j�I�|1����if{-Ʉi5�ᰰU�ǚE�Rt�c7��O��EV�JHs���� �Ո�͛/��x=��R��4�6�v�g{�����Ō��P?	y�ښU��� (UR�������s�S���b�i��c����?z����k�k��h1��6�,�����V�$��oI���� �n:����y�Ff�k����:�k!�(C%��ŷ��6�$�c���ؤ�ݏ~�^�T~��&ۉdx�nt
�B�|@L6<'�+�d�*��׈����{9�Ѕ�G��{}U-�_EUP��`4�����,X!,Z� Ὅ.�sN�,+�۬xXXP����u}d�O�^AK'aUN�l�utf]���<N���M<Dcg(d�n���ϾK�������e���a&�{��+j�C�UQ�}���\��0S9��4�!h�q����ה��e]��]U�;p�R�჉t#X�KW"�3`�N2&@�|à�sK��鋿��^��~[Z����[v�)�VB���� E��!��)���P�l��=���X���V�+�[�s
_8�wՃ�0#a�-�B��+ȭ���*�n���`���2�ʄ�r�<�A��şz8�x�e%K�Y�Y"܃j��OxŗƤ<H����Y��|������O�O�J��:��:��¡Woed ��c��TsX�,U�Ξ����YG�n�O�[����s@�F���b�|��_�W%|J��x���7'Ώ6q	oHz�3�� G#��}W������E�I�!���{X�!|�>�n�eH��@�g~�Z�'��[��|D��BtV�a��3�f��m� Rp��`���NA(w��(޽!��#E=I����^4g�YAF�g/whȏY)ۀ�
 b}�����J�eiO�~���og�g�Sg{�rʏ�ͼ�Hq<��Sh6�ӉP�+y��c1�Gh����f��J�~��9��ʘ���7���ո��!��٦Tɀ/��CײLJ����9(u�٬x҃�`^��u�#d�H�0��̍�ĸ+r攛�v����6'�U��K������0�g?s��bB��<�j�=��:����pD?Kx�k�����5��ޫ���C	�@���T5�|>iMw��"+��E�d�\)���.�}�?���?�Li8|��rG¯�H������է��@�i�6:#����\��8ݦT��1��R������
T�7U�T<,�9�"^;g�	�-���S@��I��)�#��$��1��T`�G�?2���Ҋ��ŠaP��v%*���1Ů���tZý�:]�����1S�?�5�!�g\>vA�>�"X=L�	�����
0�,��L)��TRم�� Y����K]ȏ�/��_��&!3��㚥������x�*�L�ڥ�+�޸X�F��S��5�}��.���{?�*�A8MX��g1l�G��߶�)f�q �9�Z����P��n[C������\�b(�o!��I�N��E��F�Bv�L�� ���>���^�q7��֞����q��!�	p�o�������<D s��;{�2�,��Xy�~��(�����ۣ�����3x]c�N�%�A�R�V��eM������|/����^��w�4~������z�Xf�s�L���yY���OI��d%X�0pF�G�@�#����WKVD(s2��<����I���C"�4o�k\z���Y���noB�{����xIK�?
`32�p]��Q��J^L�4)��!���ZKxf:�}z@��s�ОއA���~G�/���>�+�%��>��'k��>|N�;S#:�	D0�|���������dU.Ay%���A���&�xOF)SJ�B���X(�G��6Xϋ�	kw�}��3,�saʃ<�xWX`�+D~}n��g�6��W�d�ӞM���tt�ݦӁ��"߀�a9.�X=��ܩC�?C��g��K%�"/��ק�A���?�?)�9      �      x������ � �      �      x������ � �      �      x������ � �      �       x�3����v�4����̲T�=... j��      �   "   x�3�t�/)���4����̲T�=... ��<      �      x������ � �            x������ � �      +   w  x�͒Kk�0����Hwz\I~(:t1�M7��K�hj[S�__'LJ(�@]iq�����@�3�>�8{�;?aY�*a�?�b���\��o�19"�kP�5�j�'{6i��.�v��2�`:�>�O�L�v M�E��!/&�Q�i�8���h��R@G��RQ 
��a��I�8�����!���-܎JAUK�z�v��k�p�W4��e!�����sZ�ײ8�vh�+  W �����Ŏ�)�ح��XJʷ�aq��|�c����?~���T�G*�Ôr��y�KAo��u���#Y��G���l�%~w�]��mM�ۥ����;jZ;PS;m\ct���BȦ���tM�9h�uJRԇFH�`@�!�F�p�         4   x�3�<ܘ�P|l�Bn�BIb�B^��]��8c�(1�$�,�1\1z\\\ z�O            x�3�<ܘϙ�\�Y���G\1z\\\ ��            x������ � �      	      x������ � �            x������ � �            x������ � �            x������ � �         �   x�3�JM/�I,:� <�8�����d�䌇���(�d>��^�P�p��L���L^Fb��Ba��]��/�W(�8����y�
y�T�)<�=���w�T��*�^X�P�p�^��̇��� U������@c�&mRH���� ud^����*��LL.�,K�4��#�=... �qc�            x������ � �         n   x�3���,�(��K/���H�L�34rH�M���K��ɪ%���y8z�U�:�z:�V��W�襺g���y�fY������y�'e���:�����b���� �*            x������ � �            x������ � �            x������ � �         6   x�3�t>�0�31�$�,�Ӑ3Ə����B��R��R��������(����� /�
�            x������ � �      !      x������ � �      #      x������ � �      %      x������ � �      '      x������ � �     