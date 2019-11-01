--
-- PostgreSQL database dump
--

-- Dumped from database version 12.0
-- Dumped by pg_dump version 12.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: avg_prev_pp36(integer, date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.avg_prev_pp36(pid integer, before_date date, limit_back integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN   
(
				SELECT
					*
				FROM
					stat_line_points slp
				WHERE
					season = slp.season
					AND slp."date" < before_date
					AND slp.fdpp36 IS NOT NULL
					AND slp.player_id = pid
				ORDER BY
					date DESC
				LIMIT limit_back);
   
END; $$;


ALTER FUNCTION public.avg_prev_pp36(pid integer, before_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: clean_differences(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.clean_differences(player_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	-- RETURN regexp_replace(replace(replace(replace(player_name, ' III', ''), ' Jr.', ''), ' Sr.', ''), '(III)(Sr.)(Jr.)[.,'']', '', 'g');
 	RETURN regexp_replace(player_name, '( II)|( III)|( IV)||( Sr\.)|( Jr\.)|[.,'']', '', 'g');
 END; $$;


ALTER FUNCTION public.clean_differences(player_name text) OWNER TO jackschultz;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: players; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.players (
    id integer NOT NULL,
    dk_name character varying(100),
    fd_name character varying(100),
    br_name character varying(100),
    rg_name character varying(100),
    fte_name character varying(100),
    alt_name character varying(100)
);


ALTER TABLE public.players OWNER TO nbauser;

--
-- Name: compare_exact_clean_name_columns(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_exact_clean_name_columns(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where clean_differences(dk_name) = clean_differences(player_name)  or
 											 clean_differences(fd_name) = clean_differences(player_name)  or
 											 clean_differences(br_name) = clean_differences(player_name)  or
 											 clean_differences(rg_name) = clean_differences(player_name)  or
 											 clean_differences(fte_name) = clean_differences(player_name) or
 											 clean_differences(alt_name) = clean_differences(player_name) ;
 END; $$;


ALTER FUNCTION public.compare_exact_clean_name_columns(player_name text) OWNER TO jackschultz;

--
-- Name: compare_exact_name_columns(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_exact_name_columns(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where dk_name  = player_name or
 											 fd_name  = player_name or
 											 br_name  = player_name or
 											 rg_name  = player_name or
 											 fte_name = player_name or
 											 alt_name = player_name;
 END; $$;


ALTER FUNCTION public.compare_exact_name_columns(player_name text) OWNER TO jackschultz;

--
-- Name: compare_exact_name_columns_like(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_exact_name_columns_like(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where dk_name  like '%' || player_name || '%' or
 											 fd_name  like '%' || player_name || '%' or
 											 br_name  like '%' || player_name || '%' or 
 											 rg_name  like '%' || player_name || '%' or 
 											 fte_name like '%' || player_name || '%' or
 											 alt_name like '%' || player_name || '%';
 END; $$;


ALTER FUNCTION public.compare_exact_name_columns_like(player_name text) OWNER TO jackschultz;

--
-- Name: compare_lowercase_names(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_lowercase_names(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where lower(dk_name) = lower(player_name)  or
 											 lower(fd_name) = lower(player_name)  or
 											 lower(br_name) = lower(player_name)  or
 											 lower(rg_name) = lower(player_name)  or
 											 lower(fte_name) = lower(player_name) or
 											 lower(alt_name) = lower(player_name) ;
 END; $$;


ALTER FUNCTION public.compare_lowercase_names(player_name text) OWNER TO jackschultz;

--
-- Name: compare_non_vowel_names(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_non_vowel_names(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where remove_non_ascii_and_vowels(dk_name) = remove_non_ascii_and_vowels(player_name) or remove_non_ascii_and_vowels(fd_name)=remove_non_ascii_and_vowels(player_name)  or remove_non_ascii_and_vowels(br_name)=remove_non_ascii_and_vowels(player_name)  or  remove_non_ascii_and_vowels(rg_name)=remove_non_ascii_and_vowels(player_name)  or remove_non_ascii_and_vowels(fte_name)=remove_non_ascii_and_vowels(player_name) or remove_non_ascii_and_vowels(alt_name)=remove_non_ascii_and_vowels(player_name);
 END; $$;


ALTER FUNCTION public.compare_non_vowel_names(player_name text) OWNER TO jackschultz;

--
-- Name: compare_unaccented_names(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.compare_unaccented_names(player_name text) RETURNS SETOF public.players
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN QUERY select * from players where unaccent(dk_name) = unaccent(player_name)  or
 											 unaccent(fd_name) = unaccent(player_name)  or
 											 unaccent(br_name) = unaccent(player_name)  or
 											 unaccent(rg_name) = unaccent(player_name)  or
 											 unaccent(fte_name) = unaccent(player_name) or
 											 unaccent(alt_name) = unaccent(player_name);
 END; $$;


ALTER FUNCTION public.compare_unaccented_names(player_name text) OWNER TO jackschultz;

--
-- Name: create_update_self_projection(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.create_update_self_projection(on_date date, limit_back integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	round((avg_fd_pp36 * (minutes / 36.0)), 2) AS fd_points,
	dk_points,
	avg_fd_pp36 AS fdpp36,
	'0.1-' || limit_back as version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round(sl.minutes, 2) AS minutes,
		(
			SELECT
				round(avg(slp.fdpp36), 2)
			FROM
				stat_line_points slp
			WHERE
				slp.slid in(
					SELECT
						slid FROM stat_line_points slp2
					WHERE
						season = g.season
						AND slp2. "date" < g.date
						AND slp2.fdpp36 IS NOT NULL
						AND slp2.player_id = sl.player_id
					ORDER BY
						date DESC
					LIMIT limit_back)) AS avg_fd_pp36,
			(
				SELECT
					aver
				FROM
					dk_sal_stats
				WHERE
					sal = dk_salary) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
			DO
			UPDATE
			SET
				stat_line_id = excluded.stat_line_id,
				minutes = excluded.minutes,
				fd_points = excluded.fd_points,
				dk_points = excluded.dk_points,
				fdpp36 = excluded.fdpp36;
END;
$$;


ALTER FUNCTION public.create_update_self_projection(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: date_to_season(date); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.date_to_season(gdate date) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	current_year int := extract(year FROM gdate);
	current_month int := extract(month FROM gdate);
	prev_year int := extract(year FROM (gdate - interval '1 year'));
	next_year int := extract(year FROM (gdate + interval '1 year'));
	retval text;
BEGIN
	CASE WHEN current_month < 7 THEN
		retval := (prev_year % 100) || '-' || (current_year % 100);
ELSE
	retval := (current_year % 100) || '-' || (next_year % 100);
END CASE;
RETURN retval;
END;
$$;


ALTER FUNCTION public.date_to_season(gdate date) OWNER TO jackschultz;

--
-- Name: last_stat_line_points_before_date(integer, date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.last_stat_line_points_before_date(pid integer, before_date date, limit_back integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN   
   	(
		SELECT
			*
		FROM
			stat_line_points slp
		WHERE
			slp.stat_line_id in(
				SELECT
					stat_line_id FROM stat_line_points slp2
				WHERE
					season = date_to_season(before_date)
					AND slp2."date" < before_date
					AND slp2.fdpp36 IS NOT NULL
					AND slp2.player_id = pid
				ORDER BY
					date DESC
				LIMIT limit_back)
		GROUP BY
			slp.player_id);
   
END; $$;


ALTER FUNCTION public.last_stat_line_points_before_date(pid integer, before_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: remove_non_ascii_and_vowels(text); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.remove_non_ascii_and_vowels(player_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
 BEGIN
 	RETURN regexp_replace(regexp_replace(player_name, '[^[:ascii:]]', '', 'g'), '[aeiou]', '', 'gi');
 END; $$;


ALTER FUNCTION public.remove_non_ascii_and_vowels(player_name text) OWNER TO jackschultz;

--
-- Name: set_self_projections_avg(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_avg(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	round((avg_fd_pp36 * (minutes / 36.0)), 2) AS fd_points,
	dk_points,
	avg_fd_pp36 AS fdpp36,
	'0.1-avg-' || lpad(limit_back::text, 2, '0') AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round(sl.minutes, 2) AS minutes,
		(
			SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(avg(slps.fdpp36), 2)
				END AS round
			FROM
				stat_line_points_before_date (sl.player_id, on_date, limit_back) as slps
		)
			AS avg_fd_pp36,
			(
				SELECT
					aver
				FROM
					dk_sal_stats
				WHERE
					sal = dk_salary) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
	DO
	UPDATE
	SET
		stat_line_id = excluded.stat_line_id,
		minutes = excluded.minutes,
		fd_points = excluded.fd_points,
		dk_points = excluded.dk_points,
		fdpp36 = excluded.fdpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_avg(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_avg_score(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_avg_score(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	fd_points,
	dk_points,
	'0.1-avg-actual-' || limit_back AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round(sl.minutes, 2) AS minutes,
		(SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(avg(fd_points), 2)
				END as aver
			FROM
				stat_line_points_before_date (sl.player_id,
					on_date,
					limit_back)) AS fd_points,
		(SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(avg(dk_points), 2)
				END as aver
			FROM
				stat_line_points_before_date (sl.player_id,
					on_date,
					limit_back)) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
			DO
			UPDATE
			SET
				stat_line_id = excluded.stat_line_id,
				minutes = excluded.minutes,
				fd_points = excluded.fd_points,
				dk_points = excluded.dk_points,
				fdpp36 = excluded.fdpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_avg_score(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_avg_w_fte_minutes(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_avg_w_fte_minutes(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	round((avg_fd_pp36 * (minutes / 36.0)), 2) AS fd_points,
	dk_points,
	avg_fd_pp36 AS fdpp36,
	'0.1-avg-fte-min-' || lpad(limit_back::text, 2, '0') AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round((
			SELECT proj.minutes FROM projections proj WHERE "source"='fte' AND proj.stat_line_id=sl.id
		), 2) AS minutes,
		(
			SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(avg(slps.fdpp36), 2)
				END AS round
			FROM
				stat_line_points_before_date (sl.player_id, on_date, limit_back) as slps
		)
			AS avg_fd_pp36,
			(
				SELECT
					aver
				FROM
					dk_sal_stats
				WHERE
					sal = dk_salary) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
	DO
	UPDATE
	SET
		stat_line_id = excluded.stat_line_id,
		minutes = excluded.minutes,
		fd_points = excluded.fd_points,
		dk_points = excluded.dk_points,
		fdpp36 = excluded.fdpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_avg_w_fte_minutes(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_med(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_med(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	round((avg_fd_pp36 * (minutes / 36.0)), 2) AS fd_points,
	dk_points,
	avg_fd_pp36 AS fdpp36,
	'0.1-med-' || limit_back AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round(sl.minutes, 2) AS minutes,
		(
			SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round((percentile_cont (0.5)
						WITHIN GROUP (order by slp.fdpp36))::NUMERIC, 2)
				END AS round
			FROM
				stat_line_points slp
			WHERE
				slp.stat_line_id in(
					SELECT
						stat_line_id FROM stat_line_points slp2
					WHERE
						season = g.season
						AND slp2. "date" < g.date
						AND slp2.fdpp36 IS NOT NULL
						AND slp2.minutes > 5
						AND slp2.player_id = sl.player_id
					ORDER BY
						date DESC
					LIMIT limit_back)) AS avg_fd_pp36,
			(
				SELECT
					aver
				FROM
					dk_sal_stats
				WHERE
					sal = dk_salary) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
			DO
			UPDATE
			SET
				stat_line_id = excluded.stat_line_id,
				minutes = excluded.minutes,
				fd_points = excluded.fd_points,
				dk_points = excluded.dk_points,
				fdpp36 = excluded.fdpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_med(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_std_ceil(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_std_ceil(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, version)
SELECT
	'self' AS source,
	stat_line_id,
	minutes,
	
	round(((avg_fd_pp36 + std_fd_pp36) * (minutes / 36.0)), 2) AS fd_points,
	dk_points,
	(avg_fd_pp36 + std_fd_pp36) AS fdpp36,
	'0.1-std-ceil-' || limit_back AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round(sl.minutes, 2) AS minutes,
		(
			SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(avg(slp.fdpp36), 2)
				END AS aver
			FROM
				stat_line_points slp
			WHERE
				slp.stat_line_id in(
					SELECT
						stat_line_id FROM stat_line_points slp2
					WHERE
						season = g.season
						AND slp2. "date" < g.date
						AND slp2.fdpp36 IS NOT NULL
						AND slp2.minutes > 5
						AND slp2.player_id = sl.player_id
					ORDER BY
						date DESC
					LIMIT limit_back)) AS avg_fd_pp36,
	
		(
			SELECT
				CASE WHEN count(*) < limit_back THEN
					NULL
				ELSE
					round(stddev(slp.fdpp36)::numeric, 2)
				END AS aver
			FROM
				stat_line_points slp
			WHERE
				slp.stat_line_id in(
					SELECT
						stat_line_id FROM stat_line_points slp2
					WHERE
						season = g.season
						AND slp2. "date" < g.date
						AND slp2.fdpp36 IS NOT NULL
						AND slp2.minutes > 5
						AND slp2.player_id = sl.player_id
					ORDER BY
						date DESC
					LIMIT limit_back)) AS std_fd_pp36,	
	
			(
				SELECT
					aver
				FROM
					dk_sal_stats
				WHERE
					sal = dk_salary) AS dk_points
			FROM
				stat_lines sl,
				games g
			WHERE
				sl.game_id = g.id
				AND sl.fd_salary IS NOT NULL
				AND sl.active
				AND g. "date" = on_date) x ON CONFLICT (source, stat_line_id, version)
			DO
			UPDATE
			SET
				stat_line_id = excluded.stat_line_id,
				minutes = excluded.minutes,
				fd_points = excluded.fd_points,
				dk_points = excluded.dk_points,
				fdpp36 = excluded.fdpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_std_ceil(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: games; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.games (
    id integer NOT NULL,
    date date NOT NULL,
    home_team_id integer NOT NULL,
    away_team_id integer NOT NULL,
    season character varying(10),
    start_time timestamp without time zone
);


ALTER TABLE public.games OWNER TO nbauser;

--
-- Name: stat_lines; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.stat_lines (
    id integer NOT NULL,
    player_id integer NOT NULL,
    team_id integer NOT NULL,
    game_id integer NOT NULL,
    dk_positions character varying(15),
    fd_positions character varying(15),
    dk_salary integer,
    fd_salary integer,
    dk_points numeric,
    fd_points numeric,
    stats jsonb,
    minutes numeric DEFAULT 0.0,
    active boolean DEFAULT true,
    dk_id character varying(31),
    fd_id character varying(31)
);


ALTER TABLE public.stat_lines OWNER TO nbauser;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    abbrv character varying(10) NOT NULL,
    rg_abbrv character varying(10) NOT NULL,
    br_abbrv character varying(10)
);


ALTER TABLE public.teams OWNER TO nbauser;

--
-- Name: stat_line_points; Type: VIEW; Schema: public; Owner: nbauser
--

CREATE VIEW public.stat_line_points AS
 SELECT p.br_name AS name,
    t.abbrv,
    g.date,
    round(sl.minutes, 2) AS minutes,
    sl.dk_positions,
    sl.dk_salary,
    round(sl.dk_points, 2) AS dk_points,
    round((sl.dk_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2) AS dkpp36,
    sl.fd_salary,
    sl.fd_positions,
    round(sl.fd_points, 2) AS fd_points,
    round((sl.fd_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2) AS fdpp36,
    sl.active,
    p.id AS player_id,
    sl.id AS stat_line_id,
    g.season
   FROM public.stat_lines sl,
    public.games g,
    public.players p,
    public.teams t
  WHERE ((sl.game_id = g.id) AND (sl.player_id = p.id) AND (sl.team_id = t.id));


ALTER TABLE public.stat_line_points OWNER TO nbauser;

--
-- Name: stat_line_points_before_date(integer, date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.stat_line_points_before_date(pid integer, before_date date, limit_back integer) RETURNS SETOF public.stat_line_points
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY (
		SELECT
			*
		FROM
			stat_line_points slp
		WHERE
			slp.stat_line_id in(
				SELECT
					stat_line_id FROM stat_line_points slp2
				WHERE
					season = date_to_season (before_date)
					AND slp2. "date" < before_date
					AND slp2.fdpp36 IS NOT NULL
					AND slp2.player_id = pid
				ORDER BY
					date DESC
				LIMIT limit_back)
		ORDER BY
			slp.date DESC);
END;
$$;


ALTER FUNCTION public.stat_line_points_before_date(pid integer, before_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: contests; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.contests (
    id integer NOT NULL,
    site_id integer NOT NULL,
    name character varying(255),
    date date NOT NULL,
    num_games integer,
    min_cash_score double precision,
    start_time bigint,
    entry_fee double precision,
    places_paid integer,
    max_entrants integer,
    total_entrants integer,
    min_cash_payout double precision,
    prize_pool integer,
    winning_score double precision,
    slate integer,
    bulk jsonb,
    max_entries integer,
    slate_title character varying(31),
    style character varying(31)
);


ALTER TABLE public.contests OWNER TO nbauser;

--
-- Name: contests_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.contests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contests_id_seq OWNER TO nbauser;

--
-- Name: contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.contests_id_seq OWNED BY public.contests.id;


--
-- Name: dk_sal_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.dk_sal_stats AS
 SELECT slp.dk_salary AS sal,
    round(avg(slp.dk_points), 2) AS aver,
    round(stddev(slp.dk_points), 2) AS std,
    round((percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((slp.dk_points)::double precision)))::numeric, 2) AS median
   FROM public.stat_line_points slp
  WHERE ((slp.minutes > (0)::numeric) AND (slp.dk_salary IS NOT NULL))
  GROUP BY slp.dk_salary
  WITH NO DATA;


ALTER TABLE public.dk_sal_stats OWNER TO nbauser;

--
-- Name: fd_sal_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.fd_sal_stats AS
 SELECT slp.fd_salary AS sal,
    round(avg(slp.fd_points), 2) AS aver,
    round(stddev(slp.fd_points), 2) AS std,
    round((percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((slp.fd_points)::double precision)))::numeric, 2) AS median
   FROM public.stat_line_points slp
  WHERE ((slp.minutes > (0)::numeric) AND (slp.fd_salary IS NOT NULL))
  GROUP BY slp.fd_salary
  WITH NO DATA;


ALTER TABLE public.fd_sal_stats OWNER TO nbauser;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_id_seq OWNER TO nbauser;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO nbauser;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: projections; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.projections (
    id integer NOT NULL,
    stat_line_id integer,
    source character varying(50),
    bulk jsonb,
    minutes numeric DEFAULT 0.0,
    dk_points numeric,
    fd_points numeric,
    active boolean DEFAULT true,
    fdpp36 numeric,
    dkpp36 numeric,
    version character varying(31) DEFAULT NULL::character varying
);


ALTER TABLE public.projections OWNER TO nbauser;

--
-- Name: projections_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.projections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projections_id_seq OWNER TO nbauser;

--
-- Name: projections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.projections_id_seq OWNED BY public.projections.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.sites (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    abbrv character varying(10) NOT NULL,
    lowcase_name character varying(50)
);


ALTER TABLE public.sites OWNER TO nbauser;

--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.sites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sites_id_seq OWNER TO nbauser;

--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: stat_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.stat_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_lines_id_seq OWNER TO nbauser;

--
-- Name: stat_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.stat_lines_id_seq OWNED BY public.stat_lines.id;


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_id_seq OWNER TO nbauser;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: contests id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.contests ALTER COLUMN id SET DEFAULT nextval('public.contests_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: projections id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.projections ALTER COLUMN id SET DEFAULT nextval('public.projections_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: stat_lines id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines ALTER COLUMN id SET DEFAULT nextval('public.stat_lines_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: contests contests_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.contests
    ADD CONSTRAINT contests_pkey PRIMARY KEY (id);


--
-- Name: contests contests_site_id_name_date_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.contests
    ADD CONSTRAINT contests_site_id_name_date_key UNIQUE (site_id, name, date);


--
-- Name: games games_date_home_team_away_team; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_date_home_team_away_team UNIQUE (date, home_team_id, away_team_id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_rg_name_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_rg_name_key UNIQUE (rg_name);


--
-- Name: projections projections_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.projections
    ADD CONSTRAINT projections_pkey PRIMARY KEY (id);


--
-- Name: projections projections_source_stat_line_id_version_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.projections
    ADD CONSTRAINT projections_source_stat_line_id_version_key UNIQUE (source, stat_line_id, version);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: stat_lines stat_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_pkey PRIMARY KEY (id);


--
-- Name: stat_lines stat_lines_player_id_game_id_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_player_id_game_id_key UNIQUE (player_id, game_id);


--
-- Name: stat_lines stat_lines_player_id_game_id_key1; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_player_id_game_id_key1 UNIQUE (player_id, game_id);


--
-- Name: teams teams_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_abbrv_key UNIQUE (abbrv);


--
-- Name: teams teams_name_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_abbrv_key UNIQUE (name, abbrv);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_rg_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_rg_abbrv_key UNIQUE (rg_abbrv);


--
-- Name: contests_date_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX contests_date_idx ON public.contests USING btree (date);


--
-- Name: games_date_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX games_date_idx ON public.games USING btree (date);


--
-- Name: players_br_name_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX players_br_name_idx ON public.players USING btree (br_name);


--
-- Name: projections_source_stat_line_id_version_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX projections_source_stat_line_id_version_idx ON public.projections USING btree (source, stat_line_id, version);


--
-- Name: projections_source_version_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX projections_source_version_idx ON public.projections USING btree (source, version);


--
-- Name: projections_version_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX projections_version_idx ON public.projections USING btree (version);


--
-- Name: stat_lines_active_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_active_idx ON public.stat_lines USING btree (active);


--
-- Name: stat_lines_dk_points_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_dk_points_idx ON public.stat_lines USING btree (dk_points);


--
-- Name: stat_lines_fd_points_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_fd_points_idx ON public.stat_lines USING btree (fd_points);


--
-- Name: stat_lines_game_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_game_id_idx ON public.stat_lines USING btree (game_id);


--
-- Name: stat_lines_game_id_player_id_team_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_game_id_player_id_team_id_idx ON public.stat_lines USING btree (game_id, player_id, team_id);


--
-- Name: stat_lines_minutes_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_minutes_idx ON public.stat_lines USING btree (minutes);


--
-- Name: stat_lines_player_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_player_id_idx ON public.stat_lines USING btree (player_id);


--
-- Name: stat_lines_team_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_team_id_idx ON public.stat_lines USING btree (team_id);


--
-- Name: contests contests_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.contests
    ADD CONSTRAINT contests_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: games games_away_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.teams(id);


--
-- Name: games games_home_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.teams(id);


--
-- Name: projections projections_stat_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.projections
    ADD CONSTRAINT projections_stat_line_id_fkey FOREIGN KEY (stat_line_id) REFERENCES public.stat_lines(id);


--
-- Name: stat_lines stat_lines_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- Name: stat_lines stat_lines_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: stat_lines stat_lines_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- PostgreSQL database dump complete
--

