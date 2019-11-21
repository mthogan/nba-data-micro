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
    alt_name character varying(100),
    dfn_name character varying(100)
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
 											 alt_name = player_name or
 											 dfn_name = player_name;
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
-- Name: set_self_projections_dfn_min_avg(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_dfn_min_avg(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, dkpp36, version)
SELECT
	'self' AS source,
	x.stat_line_id,
	y.minutes,
	round((avg_prev_fdpp36 * (minutes / 36.0)), 2) AS fd_points,
	round((avg_prev_dkpp36 * (minutes / 36.0)), 2) AS dk_points,
	avg_prev_fdpp36 AS fdpp36,
	avg_prev_dkpp36 AS dkpp36,
	'0.1-dfn-min-avg-' || lpad(limit_back::text, 2, '0') AS version
FROM stat_line_avgs_before_date_with_limit(on_date, limit_back) x,
	(
		SELECT
		sl.id AS stat_line_id,
		round((SELECT proj.minutes FROM projections proj WHERE "source"='dfn' AND "version"='0.1-dfn' AND proj.stat_line_id=sl.id), 2) AS minutes
		from stat_lines sl, games g where sl.game_id=g.id and g."date"=on_date) y where y.stat_line_id = x.stat_line_id
			
			 ON CONFLICT (source, stat_line_id, version)
	DO
	UPDATE
	SET
		minutes = excluded.minutes,
		fd_points = excluded.fd_points,
		dk_points = excluded.dk_points,
		fdpp36 = excluded.fdpp36,
		dkpp36 = excluded.dkpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_dfn_min_avg(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_dfn_min_ceil(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_dfn_min_ceil(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, dkpp36, version)
SELECT
	'self' AS source,
	x.stat_line_id,
	y.minutes,
	round((ceil_prev_fdpp36 * (minutes / 36.0)), 2) AS fd_points,
	round((ceil_prev_dkpp36 * (minutes / 36.0)), 2) AS dk_points,
	ceil_prev_fdpp36 AS fdpp36,
	ceil_prev_dkpp36 AS dkpp36,
	'0.1-dfn-min-ceil-' || lpad(limit_back::text, 2, '0') AS version
FROM stat_line_avgs_before_date_with_limit(on_date, limit_back) x,
	(
		SELECT
		sl.id AS stat_line_id,
		round((SELECT proj.minutes FROM projections proj WHERE "source"='dfn' AND "version"='0.1-dfn' AND proj.stat_line_id=sl.id), 2) AS minutes
		from stat_lines sl, games g where sl.game_id=g.id and g."date"=on_date) y where y.stat_line_id = x.stat_line_id
			
			 ON CONFLICT (source, stat_line_id, version)
	DO
	UPDATE
	SET
		minutes = excluded.minutes,
		fd_points = excluded.fd_points,
		dk_points = excluded.dk_points,
		fdpp36 = excluded.fdpp36,
		dkpp36 = excluded.dkpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_dfn_min_ceil(on_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: set_self_projections_dfn_min_floor(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.set_self_projections_dfn_min_floor(on_date date, limit_back integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	num_rows integer;
BEGIN
	INSERT INTO projections (source, stat_line_id, minutes, fd_points, dk_points, fdpp36, dkpp36, version)
SELECT
	'self' AS source,
	x.stat_line_id,
	y.minutes,
	round((floor_prev_fdpp36 * (minutes / 36.0)), 2) AS fd_points,
	round((floor_prev_dkpp36 * (minutes / 36.0)), 2) AS dk_points,
	floor_prev_fdpp36 AS fdpp36,
	floor_prev_dkpp36 AS dkpp36,
	'0.1-dfn-min-floor-' || lpad(limit_back::text, 2, '0') AS version
FROM stat_line_avgs_before_date_with_limit(on_date, limit_back) x,
	(
		SELECT
		sl.id AS stat_line_id,
		round((SELECT proj.minutes FROM projections proj WHERE "source"='dfn' AND "version"='0.1-dfn' AND proj.stat_line_id=sl.id), 2) AS minutes
		from stat_lines sl, games g where sl.game_id=g.id and g."date"=on_date) y where y.stat_line_id = x.stat_line_id
			
			 ON CONFLICT (source, stat_line_id, version)
	DO
	UPDATE
	SET
		minutes = excluded.minutes,
		fd_points = excluded.fd_points,
		dk_points = excluded.dk_points,
		fdpp36 = excluded.fdpp36,
		dkpp36 = excluded.dkpp36;
	GET DIAGNOSTICS num_rows = ROW_COUNT;
	RETURN num_rows AS num_rows;
END;
$$;


ALTER FUNCTION public.set_self_projections_dfn_min_floor(on_date date, limit_back integer) OWNER TO jackschultz;

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
	'0.1-std-ceil-dfn-min-' || limit_back AS version
FROM (
	SELECT
		sl.id AS stat_line_id,
		round((SELECT proj.minutes FROM projections proj WHERE "source"='dfn' AND "version"='0.1-dfn-json' AND proj.stat_line_id=sl.id), 2) AS minutes,
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
-- Name: stat_line_avgs_before_date_with_limit(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.stat_line_avgs_before_date_with_limit(before_date date, limit_back integer) RETURNS TABLE(stat_line_id integer, player_id integer, name character varying, date date, act_minutes numeric, act_fdpp36 numeric, act_dkpp36 numeric, avg_prev_minutes numeric, avg_prev_fdpp36 numeric, std_prev_fdpp36 numeric, avg_prev_dkpp36 numeric, std_prev_dkpp36 numeric, ceil_prev_fdpp36 numeric, floor_prev_fdpp36 numeric, ceil_prev_dkpp36 numeric, floor_prev_dkpp36 numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY (
	
with qqq as (select slp.stat_line_id, slp.player_id, slp.name, slp.date, slp.minutes as act_minutes, slp.fdpp36 as act_fdpp36, slp.dkpp36 as act_dkpp36,
 											        round(avg(slp.minutes) over lxsls, 2) as avg_prev_minutes,
												    round(avg(slp.fdpp36) over lxsls, 2) as avg_prev_fdpp36,
												    round(stddev(slp.fdpp36) over lxsls, 2) as std_prev_fdpp36,
												    round(avg(slp.dkpp36) over lxsls, 2) as avg_prev_dkpp36,
												    round(stddev(slp.dkpp36) over lxsls, 2) as std_prev_dkpp36
												    
		 from stat_line_points slp
		 where slp."date"> (before_date::date - interval '1 month')

		 window lxsls as (partition by slp.player_id order by slp."date" rows between limit_back preceding and 1 preceding)
	     order by "date" desc)
select *,
	(x.avg_prev_fdpp36 + x.std_prev_fdpp36) as ceil_prev_fdpp36,
	(x.avg_prev_fdpp36 - x.std_prev_fdpp36) as floor_prev_fdpp36,
	(x.avg_prev_dkpp36 + x.std_prev_dkpp36) as ceil_prev_dkpp36,
	(x.avg_prev_dkpp36 - x.std_prev_dkpp36) as floor_prev_dkpp36
FROM
(SELECT
	qqq.stat_line_id,
	qqq.player_id,
	qqq.name,
	qqq.date,
	COALESCE(qqq.act_minutes, 0) as act_minutes,
	COALESCE(qqq.act_dkpp36, 0) as act_dkpp36,
	COALESCE(qqq.act_fdpp36, 0) as act_fdpp36,
	COALESCE(qqq.avg_prev_minutes, 0),
	case when qqq.avg_prev_minutes > 5 then qqq.avg_prev_fdpp36 else 0 end as avg_prev_fdpp36,	case when qqq.avg_prev_minutes > 5 then qqq.std_prev_fdpp36 else 0 end as std_prev_fdpp36,
	case when qqq.avg_prev_minutes > 5 then qqq.avg_prev_dkpp36 else 0 end as avg_prev_dkpp36,
	case when qqq.avg_prev_minutes > 5 then qqq.std_prev_dkpp36 else 0 end as std_prev_dkpp36
FROM
	stat_line_points slp1
Join
	qqq on slp1.player_id = qqq.player_id and slp1."date" = qqq.date
WHERE
	slp1."date" = before_date)x
	
);
END;
$$;


ALTER FUNCTION public.stat_line_avgs_before_date_with_limit(before_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: games; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.games (
    id integer NOT NULL,
    date date NOT NULL,
    home_team_id integer NOT NULL,
    away_team_id integer NOT NULL,
    season character varying(10),
    start_time timestamp without time zone,
    home_team_score integer,
    away_team_score integer,
    scoring jsonb,
    home_team_factors jsonb,
    away_team_factors jsonb,
    num_ots integer DEFAULT 0,
    length integer,
    pace numeric,
    home_team_fd_points numeric,
    away_team_fd_points numeric,
    home_team_dk_points numeric,
    away_team_dk_points numeric,
    winning_team_id integer
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
    dk_points numeric DEFAULT 0.0,
    fd_points numeric DEFAULT 0.0,
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
    br_abbrv character varying(10),
    dfn_abbrv character varying(10)
);


ALTER TABLE public.teams OWNER TO nbauser;

--
-- Name: stat_line_points; Type: VIEW; Schema: public; Owner: nbauser
--

CREATE VIEW public.stat_line_points AS
 SELECT
        CASE
            WHEN (p.br_name IS NOT NULL) THEN p.br_name
            ELSE p.fd_name
        END AS name,
    t.abbrv,
    g.date,
    round(sl.minutes, 2) AS minutes,
    sl.dk_positions,
    sl.dk_salary,
    round(sl.dk_points, 2) AS dk_points,
    COALESCE(round((sl.dk_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2), 0.0) AS dkpp36,
    sl.fd_salary,
    sl.fd_positions,
    round(sl.fd_points, 2) AS fd_points,
    COALESCE(round((sl.fd_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2), 0.0) AS fdpp36,
    sl.active,
    p.id AS player_id,
    sl.id AS stat_line_id,
    g.season,
    g.id AS game_id,
    t.id AS team_id,
    g.pace,
    COALESCE(round((sl.dk_points * ((75)::numeric / ((NULLIF(sl.minutes, (0)::numeric) / (48)::numeric) * g.pace))), 2), 0.0) AS dkpp75poss,
    COALESCE(round((sl.fd_points * ((75)::numeric / ((NULLIF(sl.minutes, (0)::numeric) / (48)::numeric) * g.pace))), 2), 0.0) AS fdpp75poss,
    COALESCE(round(((sl.minutes / (48)::numeric) * g.pace), 2), 0.0) AS num_poss,
        CASE
            WHEN (g.home_team_id = t.id) THEN true
            ELSE false
        END AS home,
        CASE
            WHEN (EXISTS ( SELECT g2.id,
                g2.date
               FROM public.games g2
              WHERE ((g2.date < g.date) AND ((g2.away_team_id = t.id) OR (g2.home_team_id = t.id)) AND ((g.date - '1 day'::interval) = g2.date)))) THEN true
            ELSE false
        END AS b2b,
    sl.fd_id,
    sl.dk_id
   FROM public.stat_lines sl,
    public.games g,
    public.players p,
    public.teams t
  WHERE ((sl.game_id = g.id) AND (sl.player_id = p.id) AND (sl.team_id = t.id));


ALTER TABLE public.stat_line_points OWNER TO nbauser;

--
-- Name: stat_line_points_avgs_before_date(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.stat_line_points_avgs_before_date(before_date date, limit_back integer) RETURNS SETOF public.stat_line_points
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY (
	
with qqq as (select slp.player_id, slp.name, slp.date, slp.minutes as act_minutes, slp.fdpp36 as act_fdpp36, slp.dkpp36 as act_dkpp36,
 											        round(avg(slp.minutes) over lxsls, 2) as avg_prev_minutes,
												    round(avg(slp.fdpp36) over lxsls, 2) as avg_prev_fdpp36,
												    round(stddev(slp.fdpp36) over lxsls, 2) as std_prev_fdpp36,
												    round(avg(slp.fdpp36) over lxsls, 2) as avg_prev_dkpp36,
												    round(stddev(slp.dkpp36) over lxsls, 2) as std_prev_dkpp36
												    
		 from stat_line_points slp
		 where slp."date"> (before_date::date - interval '1 month')

		 window lxsls as (partition by slp.player_id order by slp."date" rows between limit_back preceding and 1 preceding)
	     order by "date" desc)
select *,
	(x.avg_prev_fdpp36 + x.std_prev_fdpp36) as ceil_prev_fdpp36,
	(x.avg_prev_fdpp36 - x.std_prev_fdpp36) as floor_prev_fdpp36,
	(x.avg_prev_dkpp36 + x.std_prev_dkpp36) as ceil_prev_dkpp36,
	(x.avg_prev_dkpp36 - x.std_prev_dkpp36) as floor_prev_dkpp36
FROM
(SELECT
	qqq.player_id,
	qqq.name,
	qqq.date,
	COALESCE(qqq.act_minutes, 0) as act_minutes,
	COALESCE(qqq.act_dkpp36, 0) as act,
	COALESCE(qqq.act_dkpp36, 0),
	COALESCE(qqq.avg_prev_minutes, 0),
	case when qqq.avg_prev_minutes > 5 then qqq.avg_prev_fdpp36 else 0 end as avg_prev_fdpp36,	case when qqq.avg_prev_minutes > 5 then qqq.std_prev_dkpp36 else 0 end as std_prev_fdpp36,
	case when qqq.avg_prev_minutes > 5 then qqq.avg_prev_dkpp36 else 0 end as avg_prev_dkpp36,
	case when qqq.avg_prev_minutes > 5 then qqq.std_prev_dkpp36 else 0 end as std_prev_dkpp36
FROM
	stat_line_points slp1
Join
	qqq on slp1.player_id = qqq.player_id and slp1."date" = qqq.date
WHERE
	slp1."date" = before_date)x
	
);
END;
$$;


ALTER FUNCTION public.stat_line_points_avgs_before_date(before_date date, limit_back integer) OWNER TO jackschultz;

--
-- Name: test_set_self_proj(date, integer); Type: FUNCTION; Schema: public; Owner: jackschultz
--

CREATE FUNCTION public.test_set_self_proj(on_date date, limit_back integer) RETURNS integer
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
	fd_points,
	dk_points,
	'0.1-test-avg-' || lpad(limit_back::text, 2, '0') AS version
FROM stat_line_avgs_before_date_with_limit(on_date, limit_back)

 ON CONFLICT (source, stat_line_id, version)
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


ALTER FUNCTION public.test_set_self_proj(on_date date, limit_back integer) OWNER TO jackschultz;

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
    start_time timestamp without time zone,
    entry_fee double precision,
    places_paid integer,
    max_entrants integer,
    total_entrants integer,
    min_cash_payout double precision,
    prize_pool integer,
    winning_score double precision,
    slate_num integer,
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
-- Name: dk_sal_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: jackschultz
--

CREATE MATERIALIZED VIEW public.dk_sal_stats AS
 SELECT slp.dk_salary AS sal,
    round(avg(slp.dk_points), 2) AS aver,
    round(stddev(slp.dk_points), 2) AS std,
    round((percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((slp.dk_points)::double precision)))::numeric, 2) AS median,
    round(avg(slp.dkpp36), 2) AS avgpp36
   FROM public.stat_line_points slp
  WHERE ((slp.minutes > (0)::numeric) AND (slp.dk_salary IS NOT NULL))
  GROUP BY slp.dk_salary
  WITH NO DATA;


ALTER TABLE public.dk_sal_stats OWNER TO jackschultz;

--
-- Name: fd_sal_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.fd_sal_stats AS
 SELECT slp.fd_salary AS sal,
    round(avg(slp.fd_points), 2) AS aver,
    round(stddev(slp.fd_points), 2) AS std,
    round((percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((slp.fd_points)::double precision)))::numeric, 2) AS median,
    round(avg(slp.fdpp36), 2) AS avgpp36
   FROM public.stat_line_points slp
  WHERE ((slp.minutes > (0)::numeric) AND (slp.fd_salary IS NOT NULL))
  GROUP BY slp.fd_salary
  WITH NO DATA;


ALTER TABLE public.fd_sal_stats OWNER TO nbauser;

--
-- Name: game_fd_points; Type: VIEW; Schema: public; Owner: jackschultz
--

CREATE VIEW public.game_fd_points AS
 SELECT x.date,
    x.home_team_id,
    x.away_team_id,
    x.home_team_name,
    x.home_fd_sum,
    x.away_team_name,
    x.away_fd_sum,
    x.game_id
   FROM ( SELECT g.date,
            hot.id AS home_team_id,
            ( SELECT teams.id
                   FROM public.teams
                  WHERE (teams.id = g.away_team_id)) AS away_team_id,
            ( SELECT teams.name
                   FROM public.teams
                  WHERE (teams.id = hot.id)) AS home_team_name,
            ( SELECT sum(slp.fd_points) AS sum
                   FROM public.stat_line_points slp
                  WHERE ((slp.date = g.date) AND (slp.team_id = hot.id))) AS home_fd_sum,
            ( SELECT teams.name
                   FROM public.teams
                  WHERE (teams.id = g.away_team_id)) AS away_team_name,
            ( SELECT sum(slp.fd_points) AS sum
                   FROM public.stat_line_points slp
                  WHERE ((slp.date = g.date) AND (slp.team_id = g.away_team_id))) AS away_fd_sum,
            g.id AS game_id
           FROM public.games g,
            public.teams hot
          WHERE (g.home_team_id = hot.id)
          GROUP BY g.date, hot.id, g.away_team_id, g.id) x;


ALTER TABLE public.game_fd_points OWNER TO jackschultz;

--
-- Name: game_infos; Type: VIEW; Schema: public; Owner: nbauser
--

CREATE VIEW public.game_infos AS
 SELECT g.date,
    g.start_time,
    home_team.name AS home_team_name,
    home_team.abbrv AS home_team_abbrv,
    away_team.name AS away_team_name,
    away_team.abbrv AS away_team_abbrv,
    g.home_team_score,
    g.away_team_score
   FROM public.games g,
    public.teams home_team,
    public.teams away_team
  WHERE ((g.home_team_id = home_team.id) AND (g.away_team_id = away_team.id));


ALTER TABLE public.game_infos OWNER TO nbauser;

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
    version character varying(31) DEFAULT NULL::character varying,
    dk_value numeric,
    fd_value numeric
);


ALTER TABLE public.projections OWNER TO nbauser;

--
-- Name: projection_versions; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.projection_versions AS
 SELECT DISTINCT projections.version
   FROM public.projections
  WHERE ((projections.version)::text <> ''::text)
  WITH NO DATA;


ALTER TABLE public.projection_versions OWNER TO nbauser;

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
-- Name: stat_line_infos; Type: VIEW; Schema: public; Owner: nbauser
--

CREATE VIEW public.stat_line_infos AS
 SELECT x.name,
    x.team_abbrv,
    x.date,
    x.minutes,
    x.dk_positions,
    x.dk_salary,
    x.dk_points,
    x.dkpp36,
    x.fd_salary,
    x.fd_positions,
    x.fd_points,
    x.fdpp36,
    x.sl_active,
    x.proj_active,
    x.proj_version,
    x.dk_proj_points,
    x.fd_proj_points,
    x.proj_minutes,
    x.slid,
    x.pid,
    x.fd_id,
    x.dk_id
   FROM ( SELECT
                CASE
                    WHEN (p.br_name IS NOT NULL) THEN p.br_name
                    ELSE p.fd_name
                END AS name,
            t.abbrv AS team_abbrv,
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
            sl.active AS sl_active,
            proj.active AS proj_active,
            proj.version AS proj_version,
            COALESCE(proj.dk_points, (0)::numeric) AS dk_proj_points,
            COALESCE(proj.fd_points, (0)::numeric) AS fd_proj_points,
            proj.minutes AS proj_minutes,
            sl.id AS slid,
            sl.player_id AS pid,
            sl.fd_id,
            sl.dk_id
           FROM ((((public.stat_lines sl
             JOIN public.games g ON ((sl.game_id = g.id)))
             JOIN public.players p ON ((sl.player_id = p.id)))
             JOIN public.teams t ON ((sl.team_id = t.id)))
             LEFT JOIN public.projections proj ON ((sl.id = proj.stat_line_id)))) x;


ALTER TABLE public.stat_line_infos OWNER TO nbauser;

--
-- Name: stat_line_windows; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.stat_line_windows AS
 SELECT qqq.stat_line_id,
    qqq.player_id,
    qqq.name,
    qqq.date,
    qqq.team_id,
    qqq.home,
    qqq.b2b,
    qqq.active,
    qqq.fd_positions,
    qqq.dk_positions,
    qqq.fd_salary,
    qqq.dk_salary,
    qqq.act_minutes,
    qqq.sum_prev5_minutes,
    qqq.avg_prev5_minutes,
    qqq.sum_prev8_minutes,
    qqq.avg_prev8_minutes,
    qqq.sum_prev10_minutes,
    qqq.avg_prev10_minutes,
    qqq.fird5,
    qqq.fird8,
    qqq.fird10,
    qqq.fd_act_points,
    qqq.fd_act_pp36,
    qqq.fd_avg_prev5_pp36,
    qqq.fd_std_prev5_pp36,
    qqq.fd_avg_prev8_pp36,
    qqq.fd_std_prev8_pp36,
    qqq.fd_avg_prev10_pp36,
    qqq.fd_std_prev10_pp36,
    qqq.dk_act_points,
    qqq.dk_act_pp36,
    qqq.dk_avg_prev5_pp36,
    qqq.dk_std_prev5_pp36,
    qqq.dk_avg_prev8_pp36,
    qqq.dk_std_prev8_pp36,
    qqq.dk_avg_prev10_pp36,
    qqq.dk_std_prev10_pp36,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird5 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid5,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird8 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid8,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird10 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid10,
    (qqq.fd_avg_prev5_pp36 + qqq.fd_std_prev5_pp36) AS fd_ceil_prev5_pp36,
    (qqq.fd_avg_prev5_pp36 - qqq.fd_std_prev5_pp36) AS fd_floor_prev5_pp36,
    (qqq.fd_avg_prev8_pp36 + qqq.fd_std_prev8_pp36) AS fd_ceil_prev8_pp36,
    (qqq.fd_avg_prev8_pp36 - qqq.fd_std_prev8_pp36) AS fd_floor_prev8_pp36,
    (qqq.fd_avg_prev10_pp36 + qqq.fd_std_prev10_pp36) AS fd_ceil_prev10_pp36,
    (qqq.fd_avg_prev10_pp36 - qqq.fd_std_prev10_pp36) AS fd_floor_prev10_pp36,
    (qqq.dk_avg_prev5_pp36 + qqq.dk_std_prev5_pp36) AS dk_ceil_prev5_pp36,
    (qqq.dk_avg_prev5_pp36 - qqq.dk_std_prev5_pp36) AS dk_floor_prev5_pp36,
    (qqq.dk_avg_prev8_pp36 + qqq.dk_std_prev8_pp36) AS dk_ceil_prev8_pp36,
    (qqq.dk_avg_prev8_pp36 - qqq.dk_std_prev8_pp36) AS dk_floor_prev8_pp36,
    (qqq.dk_avg_prev10_pp36 + qqq.dk_std_prev10_pp36) AS dk_ceil_prev10_pp36,
    (qqq.dk_avg_prev10_pp36 - qqq.dk_std_prev10_pp36) AS dk_floor_prev10_pp36
   FROM ( SELECT slp.stat_line_id,
            slp.player_id,
            slp.name,
            slp.date,
            slp.team_id,
            slp.home,
            slp.b2b,
            slp.active,
            slp.fd_positions,
            slp.dk_positions,
            slp.fd_salary,
            slp.dk_salary,
            COALESCE(slp.minutes, 0.0) AS act_minutes,
            round(sum(slp.minutes) OVER l5sls, 2) AS sum_prev5_minutes,
            round(avg(slp.minutes) OVER l5sls, 2) AS avg_prev5_minutes,
            round(sum(slp.minutes) OVER l8sls, 2) AS sum_prev8_minutes,
            round(avg(slp.minutes) OVER l8sls, 2) AS avg_prev8_minutes,
            round(sum(slp.minutes) OVER l10sls, 2) AS sum_prev10_minutes,
            round(avg(slp.minutes) OVER l10sls, 2) AS avg_prev10_minutes,
            first_value(slp.date) OVER l5sls AS fird5,
            first_value(slp.date) OVER l8sls AS fird8,
            first_value(slp.date) OVER l10sls AS fird10,
            COALESCE(slp.fd_points, 0.0) AS fd_act_points,
            COALESCE(slp.fdpp36, 0.0) AS fd_act_pp36,
            round(avg(slp.fdpp36) OVER l5sls, 2) AS fd_avg_prev5_pp36,
            round(stddev(slp.fdpp36) OVER l5sls, 2) AS fd_std_prev5_pp36,
            round(avg(slp.fdpp36) OVER l8sls, 2) AS fd_avg_prev8_pp36,
            round(stddev(slp.fdpp36) OVER l8sls, 2) AS fd_std_prev8_pp36,
            round(avg(slp.fdpp36) OVER l10sls, 2) AS fd_avg_prev10_pp36,
            round(stddev(slp.fdpp36) OVER l10sls, 2) AS fd_std_prev10_pp36,
            COALESCE(slp.dk_points, 0.0) AS dk_act_points,
            COALESCE(slp.dkpp36, 0.0) AS dk_act_pp36,
            round(avg(slp.dkpp36) OVER l5sls, 2) AS dk_avg_prev5_pp36,
            round(stddev(slp.dkpp36) OVER l5sls, 2) AS dk_std_prev5_pp36,
            round(avg(slp.dkpp36) OVER l8sls, 2) AS dk_avg_prev8_pp36,
            round(stddev(slp.dkpp36) OVER l8sls, 2) AS dk_std_prev8_pp36,
            round(avg(slp.dkpp36) OVER l10sls, 2) AS dk_avg_prev10_pp36,
            round(stddev(slp.dkpp36) OVER l10sls, 2) AS dk_std_prev10_pp36
           FROM public.stat_line_points slp
          WINDOW l5sls AS (PARTITION BY slp.player_id ORDER BY slp.date ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING), l8sls AS (PARTITION BY slp.player_id ORDER BY slp.date ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING), l10sls AS (PARTITION BY slp.player_id ORDER BY slp.date ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)) qqq
  WITH NO DATA;


ALTER TABLE public.stat_line_windows OWNER TO nbauser;

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
-- Name: team_points_windows; Type: MATERIALIZED VIEW; Schema: public; Owner: nbauser
--

CREATE MATERIALIZED VIEW public.team_points_windows AS
 SELECT x.date,
    x.game_id,
    x.team_abbrv,
    x.team_id,
    x.game_pace,
    x.b2b,
    x.winning_team_id,
    x.opponent_id,
    x.pts_scored,
    x.pts_given,
    sum(
        CASE
            WHEN (x.winning_team_id = x.team_id) THEN 1
            ELSE 0
        END) OVER l5gs AS l5_wins,
    sum(
        CASE
            WHEN (x.winning_team_id = x.team_id) THEN 1
            ELSE 0
        END) OVER l8gs AS l8_wins,
    sum(
        CASE
            WHEN (x.winning_team_id = x.team_id) THEN 1
            ELSE 0
        END) OVER l10gs AS l10_wins,
    round(avg(x.pts_scored) OVER l5gs, 2) AS l5gps,
    round(avg(x.pts_scored) OVER l8gs, 2) AS l8gps,
    round(avg(x.pts_scored) OVER l10gs, 2) AS l10gps,
    round(avg(x.pts_given) OVER l5gs, 2) AS l5gpg,
    round(avg(x.pts_given) OVER l8gs, 2) AS l8gpg,
    round(avg(x.pts_given) OVER l10gs, 2) AS l10gpg,
    round(avg(x.game_pace) OVER l5gs, 2) AS l5gpace,
    round(avg(x.game_pace) OVER l8gs, 2) AS l8gpace,
    round(avg(x.game_pace) OVER l10gs, 2) AS l10gpace,
    round(avg(x.fd_pts_given_pg) OVER l8gs, 2) AS l8_fd_pts_given_pg,
    round(avg(x.fd_pts_given_sg) OVER l8gs, 2) AS l8_fd_pts_given_sg,
    round(avg(x.fd_pts_given_sf) OVER l8gs, 2) AS l8_fd_pts_given_sf,
    round(avg(x.fd_pts_given_pf) OVER l8gs, 2) AS l8_fd_pts_given_pf,
    round(avg(x.fd_pts_given_c) OVER l8gs, 2) AS l8_fd_pts_given_c,
    round(avg(x.fd_pp36_given_pg) OVER l5gs, 2) AS l5_fd_pp36_given_pg,
    round(avg(x.fd_pp36_given_sg) OVER l5gs, 2) AS l5_fd_pp36_given_sg,
    round(avg(x.fd_pp36_given_sf) OVER l5gs, 2) AS l5_fd_pp36_given_sf,
    round(avg(x.fd_pp36_given_pf) OVER l5gs, 2) AS l5_fd_pp36_given_pf,
    round(avg(x.fd_pp36_given_c) OVER l5gs, 2) AS l5_fd_pp36_given_c,
    round(avg(x.fd_pp36_given_pg) OVER l8gs, 2) AS l8_fd_pp36_given_pg,
    round(avg(x.fd_pp36_given_sg) OVER l8gs, 2) AS l8_fd_pp36_given_sg,
    round(avg(x.fd_pp36_given_sf) OVER l8gs, 2) AS l8_fd_pp36_given_sf,
    round(avg(x.fd_pp36_given_pf) OVER l8gs, 2) AS l8_fd_pp36_given_pf,
    round(avg(x.fd_pp36_given_c) OVER l8gs, 2) AS l8_fd_pp36_given_c,
    round(avg(x.fd_pp36_given_pg) OVER l10gs, 2) AS l10_fd_pp36_given_pg,
    round(avg(x.fd_pp36_given_sg) OVER l10gs, 2) AS l10_fd_pp36_given_sg,
    round(avg(x.fd_pp36_given_sf) OVER l10gs, 2) AS l10_fd_pp36_given_sf,
    round(avg(x.fd_pp36_given_pf) OVER l10gs, 2) AS l10_fd_pp36_given_pf,
    round(avg(x.fd_pp36_given_c) OVER l10gs, 2) AS l10_fd_pp36_given_c,
    round(avg(x.dk_pts_given_pg) OVER l8gs, 2) AS l8_dk_pts_given_pg,
    round(avg(x.dk_pts_given_sg) OVER l8gs, 2) AS l8_dk_pts_given_sg,
    round(avg(x.dk_pts_given_sf) OVER l8gs, 2) AS l8_dk_pts_given_sf,
    round(avg(x.dk_pts_given_pf) OVER l8gs, 2) AS l8_dk_pts_given_pf,
    round(avg(x.dk_pts_given_c) OVER l8gs, 2) AS l8_dk_pts_given_c
   FROM ( SELECT g.date,
            g.id AS game_id,
            t.abbrv AS team_abbrv,
            t.id AS team_id,
            g.pace AS game_pace,
                CASE
                    WHEN (EXISTS ( SELECT g2.id,
                        g2.date
                       FROM public.games g2
                      WHERE ((g2.date < g.date) AND ((g2.away_team_id = t.id) OR (g2.home_team_id = t.id)) AND ((g.date - '1 day'::interval) = g2.date)))) THEN true
                    ELSE false
                END AS b2b,
            g.winning_team_id,
                CASE
                    WHEN (t.id = g.home_team_id) THEN g.away_team_id
                    ELSE g.home_team_id
                END AS opponent_id,
            round(
                CASE
                    WHEN (t.id = g.home_team_id) THEN (g.home_team_fd_points - 3.5)
                    ELSE (g.away_team_fd_points + 3.5)
                END, 2) AS pts_scored,
            round(
                CASE
                    WHEN (t.id = g.home_team_id) THEN (g.away_team_fd_points + 3.5)
                    ELSE (g.home_team_fd_points - 3.5)
                END, 2) AS pts_given,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'PG'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pts_given_pg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'SG'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pts_given_sg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'SF'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pts_given_sf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'PF'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pts_given_pf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'C'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pts_given_c,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fdpp36 AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'PG'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pp36_given_pg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fdpp36 AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'SG'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pp36_given_sg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fdpp36 AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'SF'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pp36_given_sf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fdpp36 AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'PF'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pp36_given_pf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fdpp36 AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.fd_positions)::text ~~ 'C'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS fd_pp36_given_c,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.dk_positions)::text ~~ '%PG%'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS dk_pts_given_pg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.dk_positions)::text ~~ '%SG%'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS dk_pts_given_sg,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.dk_positions)::text ~~ '%SF%'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS dk_pts_given_sf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.dk_positions)::text ~~ '%PF%'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS dk_pts_given_pf,
            ( SELECT avg(x_1.pg_pts) AS avg
                   FROM ( SELECT slp.fd_points AS pg_pts
                           FROM public.stat_line_points slp
                          WHERE ((slp.game_id = g.id) AND ((slp.dk_positions)::text ~~ '%C%'::text) AND slp.active AND (slp.minutes > (10)::numeric))) x_1) AS dk_pts_given_c
           FROM public.games g,
            public.teams t
          WHERE ((g.home_team_id = t.id) OR (g.away_team_id = t.id))
          ORDER BY g.date) x
  WINDOW l5gs AS (PARTITION BY x.team_abbrv ORDER BY x.date ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING), l8gs AS (PARTITION BY x.team_abbrv ORDER BY x.date ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING), l10gs AS (PARTITION BY x.team_abbrv ORDER BY x.date ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)
  WITH NO DATA;


ALTER TABLE public.team_points_windows OWNER TO nbauser;

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
-- Name: test_proj_view; Type: VIEW; Schema: public; Owner: nbauser
--

CREATE VIEW public.test_proj_view AS
 SELECT slw.date,
    slw.player_id,
    slw.stat_line_id,
    slw.team_id,
    slw.fd_salary,
    slw.dk_salary,
    slw.fd_act_pp36,
    slw.avg_prev5_minutes,
    slw.avg_prev8_minutes,
    slw.avg_prev10_minutes,
    slw.fd_avg_prev5_pp36,
    slw.fd_avg_prev8_pp36,
    slw.fd_avg_prev10_pp36,
    slw.fd_std_prev5_pp36,
    slw.fd_std_prev8_pp36,
    slw.fd_std_prev10_pp36,
    slw.home,
    tpw.b2b AS team_b2b,
    opw.b2b AS opp_b2b,
    tpw.l5gps AS team_l5gps,
    tpw.l8gps AS team_l8gps,
    tpw.l10gps AS team_l10gps,
    tpw.l5gpace AS team_l5gpace,
    tpw.l8gpace AS team_l8gpace,
    tpw.l10gpace AS team_l10gpace,
    tpw.l5gpg AS team_l5gpg,
    tpw.l8gpg AS team_l8gpg,
    tpw.l10gpg AS team_l10gpg,
    tpw.l5_wins AS team_l5_wins,
    tpw.l8_wins AS team_l8_wins,
    tpw.l10_wins AS team_l10_wins,
    opw.l5gps AS opp_l5gps,
    opw.l8gps AS opp_l8gps,
    opw.l10gps AS opp_l10gps,
    opw.l5gpace AS opp_l5gpace,
    opw.l8gpace AS opp_l8gpace,
    opw.l10gpace AS opp_l10gpace,
    opw.l5gpg AS opp_l5gpg,
    opw.l8gpg AS opp_l8gpg,
    opw.l10gpg AS opp_l10gpg,
    opw.l5_wins AS opp_l5_wins,
    opw.l8_wins AS opp_l8_wins,
    opw.l10_wins AS opp_l10_wins,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l8_fd_pts_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l8_fd_pts_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l8_fd_pts_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l8_fd_pts_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l8_fd_pts_given_c
            ELSE NULL::numeric
        END AS opw_pts_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l5_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l5_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l5_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l5_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l5_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l5_pp36_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l8_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l8_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l8_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l8_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l8_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l8_pp36_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l10_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l10_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l10_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l10_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l10_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l10_pp36_given_pos
   FROM public.stat_line_windows slw,
    public.team_points_windows tpw,
    public.team_points_windows opw
  WHERE ((slw.date = tpw.date) AND (slw.team_id = tpw.team_id) AND (tpw.opponent_id = opw.team_id) AND (opw.date = slw.date) AND (slw.fd_positions IS NOT NULL) AND (slw.fd_salary IS NOT NULL) AND slw.valid5 AND slw.valid8 AND slw.valid10);


ALTER TABLE public.test_proj_view OWNER TO nbauser;

--
-- Name: test_proj_view2; Type: VIEW; Schema: public; Owner: jackschultz
--

CREATE VIEW public.test_proj_view2 AS
 SELECT slw.date,
    slw.player_id,
    slw.stat_line_id,
    slw.fd_act_pp36,
    slw.avg_prev5_minutes,
    slw.avg_prev8_minutes,
    slw.avg_prev10_minutes,
    slw.fd_avg_prev5_pp36,
    slw.fd_avg_prev8_pp36,
    slw.fd_avg_prev10_pp36,
    slw.fd_std_prev5_pp36,
    slw.fd_std_prev8_pp36,
    slw.fd_std_prev10_pp36,
    slw.home,
    tpw.b2b AS team_b2b,
    opw.b2b AS opp_b2b,
    tpw.l5gps AS team_l5gps,
    tpw.l8gps AS team_l8gps,
    tpw.l10gps AS team_l10gps,
    tpw.l5gpace AS team_l5gpace,
    tpw.l8gpace AS team_l8gpace,
    tpw.l10gpace AS team_l10gpace,
    tpw.l5gpg AS team_l5gpg,
    tpw.l8gpg AS team_l8gpg,
    tpw.l10gpg AS team_l10gpg,
    tpw.l5_wins AS team_l5_wins,
    tpw.l8_wins AS team_l8_wins,
    tpw.l10_wins AS team_l10_wins,
    opw.l5gps AS opp_l5gps,
    opw.l8gps AS opp_l8gps,
    opw.l10gps AS opp_l10gps,
    opw.l5gpace AS opp_l5gpace,
    opw.l8gpace AS opp_l8gpace,
    opw.l10gpace AS opp_l10gpace,
    opw.l5gpg AS opp_l5gpg,
    opw.l8gpg AS opp_l8gpg,
    opw.l10gpg AS opp_l10gpg,
    opw.l5_wins AS opp_l5_wins,
    opw.l8_wins AS opp_l8_wins,
    opw.l10_wins AS opp_l10_wins,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l8_fd_pts_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l8_fd_pts_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l8_fd_pts_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l8_fd_pts_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l8_fd_pts_given_c
            ELSE NULL::numeric
        END AS opw_pts_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l5_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l5_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l5_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l5_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l5_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l5_pp36_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l8_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l8_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l8_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l8_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l8_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l8_pp36_given_pos,
        CASE
            WHEN ((slw.fd_positions)::text ~~ 'PG'::text) THEN opw.l10_fd_pp36_given_pg
            WHEN ((slw.fd_positions)::text ~~ 'SG'::text) THEN opw.l10_fd_pp36_given_sg
            WHEN ((slw.fd_positions)::text ~~ 'SF'::text) THEN opw.l10_fd_pp36_given_sf
            WHEN ((slw.fd_positions)::text ~~ 'PF'::text) THEN opw.l10_fd_pp36_given_pf
            WHEN ((slw.fd_positions)::text ~~ 'C'::text) THEN opw.l10_fd_pp36_given_c
            ELSE NULL::numeric
        END AS opw_l10_pp36_given_pos
   FROM public.stat_line_windows slw,
    public.team_points_windows tpw,
    public.team_points_windows opw
  WHERE ((slw.date = tpw.date) AND (slw.team_id = tpw.team_id) AND (tpw.opponent_id = opw.team_id) AND (opw.date = slw.date) AND (slw.fd_positions IS NOT NULL) AND (slw.fd_salary IS NOT NULL));


ALTER TABLE public.test_proj_view2 OWNER TO jackschultz;

--
-- Name: test_stat_line_points; Type: VIEW; Schema: public; Owner: jackschultz
--

CREATE VIEW public.test_stat_line_points AS
 SELECT
        CASE
            WHEN (p.br_name IS NOT NULL) THEN p.br_name
            ELSE p.fd_name
        END AS name,
    t.abbrv,
    g.date,
    round(sl.minutes, 2) AS minutes,
    sl.dk_positions,
    sl.dk_salary,
    round(sl.dk_points, 2) AS dk_points,
    COALESCE(round((sl.dk_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2), 0.0) AS dkpp36,
    COALESCE(round((sl.dk_points * ((75)::numeric / ((NULLIF(sl.minutes, (0)::numeric) / (48)::numeric) * g.pace))), 2), 0.0) AS dkpp75poss,
    sl.fd_salary,
    sl.fd_positions,
    round(sl.fd_points, 2) AS fd_points,
    COALESCE(round((sl.fd_points * (36.0 / NULLIF(sl.minutes, (0)::numeric))), 2), 0.0) AS fdpp36,
    COALESCE(round((sl.fd_points * ((75)::numeric / ((NULLIF(sl.minutes, (0)::numeric) / (48)::numeric) * g.pace))), 2), 0.0) AS fdpp75poss,
    sl.active,
    p.id AS player_id,
    sl.id AS stat_line_id,
    g.season,
    g.id AS game_id,
    t.id AS team_id,
    g.pace AS game_pace
   FROM public.stat_lines sl,
    public.games g,
    public.players p,
    public.teams t
  WHERE ((sl.game_id = g.id) AND (sl.player_id = p.id) AND (sl.team_id = t.id));


ALTER TABLE public.test_stat_line_points OWNER TO jackschultz;

--
-- Name: test_stat_line_windows; Type: MATERIALIZED VIEW; Schema: public; Owner: jackschultz
--

CREATE MATERIALIZED VIEW public.test_stat_line_windows AS
 WITH qqq AS (
         SELECT slp_1.stat_line_id,
            slp_1.player_id,
            slp_1.name,
            slp_1.date,
            slp_1.pace AS game_pace,
            COALESCE(slp_1.minutes, 0.0) AS act_minutes,
            round(sum(slp_1.minutes) OVER l5sls, 2) AS sum_prev5_minutes,
            round(avg(slp_1.minutes) OVER l5sls, 2) AS avg_prev5_minutes,
            round(sum(slp_1.minutes) OVER l10sls, 2) AS sum_prev10_minutes,
            round(avg(slp_1.minutes) OVER l10sls, 2) AS avg_prev10_minutes,
            first_value(slp_1.date) OVER l5sls AS fird5,
            first_value(slp_1.date) OVER l10sls AS fird10,
            COALESCE(slp_1.fd_points, 0.0) AS fd_act_points,
            COALESCE(slp_1.fdpp36, 0.0) AS fd_act_pp36,
            round(avg(slp_1.fdpp36) OVER l5sls, 2) AS fd_avg_prev5_pp36,
            round(stddev(slp_1.fdpp36) OVER l5sls, 2) AS fd_std_prev5_pp36,
            round(avg(((((slp_1.fdpp36 / 36.0) * ((48)::numeric / slp_1.pace)) * (100)::numeric) * 0.75)) OVER l5sls, 2) AS fd_avg_prev5_pp36_100pos,
            round(avg(((((slp_1.fdpp36 / 36.0) * ((48)::numeric / slp_1.pace)) * (100)::numeric) * 0.75)) OVER l10sls, 2) AS fd_avg_prev10_pp36_100pos,
            round(avg(slp_1.fdpp36) OVER l10sls, 2) AS fd_avg_prev10_pp36,
            round(stddev(slp_1.fdpp36) OVER l10sls, 2) AS fd_std_prev10_pp36,
            COALESCE(slp_1.dk_points, 0.0) AS dk_act_points,
            COALESCE(slp_1.dkpp36, 0.0) AS dk_act_pp36,
            round(avg(slp_1.dkpp36) OVER l5sls, 2) AS dk_avg_prev5_pp36,
            round(stddev(slp_1.dkpp36) OVER l5sls, 2) AS dk_std_prev5_pp36,
            round(avg(slp_1.dkpp36) OVER l10sls, 2) AS dk_avg_prev10_pp36,
            round(stddev(slp_1.dkpp36) OVER l10sls, 2) AS dk_std_prev10_pp36
           FROM public.stat_line_points slp_1
          WHERE (slp_1.date > (slp_1.date - '30 days'::interval))
          WINDOW l3sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), l5sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING), l8sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING), l10sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)
          ORDER BY slp_1.date DESC
        )
 SELECT slp.stat_line_id,
    slp.player_id,
    slp.date,
    slp.name,
    qqq.game_pace,
    qqq.act_minutes,
    qqq.avg_prev5_minutes,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird5 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid5,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird10 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid10,
    qqq.fd_act_points,
    qqq.fd_act_pp36,
    qqq.fd_avg_prev5_pp36,
    (qqq.fd_avg_prev5_pp36 + qqq.fd_std_prev5_pp36) AS fd_ceil_prev5_pp36,
    (qqq.fd_avg_prev5_pp36 - qqq.fd_std_prev5_pp36) AS fd_floor_prev5_pp36,
    qqq.fd_avg_prev5_pp36_100pos,
    qqq.fd_avg_prev10_pp36,
    (qqq.fd_avg_prev10_pp36 + qqq.fd_std_prev10_pp36) AS fd_ceil_prev10_pp36,
    (qqq.fd_avg_prev10_pp36 - qqq.fd_std_prev10_pp36) AS fd_floor_prev10_pp36,
    qqq.fd_avg_prev10_pp36_100pos,
    qqq.dk_act_points,
    qqq.dk_act_pp36,
    qqq.dk_avg_prev5_pp36,
    (qqq.dk_avg_prev5_pp36 + qqq.dk_std_prev5_pp36) AS dk_ceil_prev5_pp36,
    (qqq.dk_avg_prev5_pp36 - qqq.dk_std_prev5_pp36) AS dk_floor_prev5_pp36,
    qqq.dk_avg_prev10_pp36,
    (qqq.dk_avg_prev10_pp36 + qqq.dk_std_prev10_pp36) AS dk_ceil_prev10_pp36,
    (qqq.dk_avg_prev10_pp36 - qqq.dk_std_prev10_pp36) AS dk_floor_prev10_pp36
   FROM (public.stat_line_points slp
     JOIN qqq ON (((slp.player_id = qqq.player_id) AND (slp.date = qqq.date))))
  WITH NO DATA;


ALTER TABLE public.test_stat_line_windows OWNER TO jackschultz;

--
-- Name: tslw; Type: VIEW; Schema: public; Owner: jackschultz
--

CREATE VIEW public.tslw AS
 WITH qqq AS (
         SELECT slp_1.stat_line_id,
            slp_1.player_id,
            slp_1.name,
            slp_1.date,
            slp_1.pace AS game_pace,
            COALESCE(slp_1.minutes, 0.0) AS act_minutes,
            COALESCE(round(((slp_1.minutes / (48)::numeric) * slp_1.pace), 2), 0.0) AS act_possessions,
            round(sum(slp_1.minutes) OVER l5sls, 2) AS sum_prev5_minutes,
            round(avg(slp_1.minutes) OVER l5sls, 2) AS avg_prev5_minutes,
            round(sum(slp_1.minutes) OVER l10sls, 2) AS sum_prev10_minutes,
            round(avg(slp_1.minutes) OVER l10sls, 2) AS avg_prev10_minutes,
            first_value(slp_1.date) OVER l5sls AS fird5,
            first_value(slp_1.date) OVER l10sls AS fird10,
            COALESCE(slp_1.fd_points, 0.0) AS fd_act_points,
            COALESCE(slp_1.fdpp36, 0.0) AS fd_act_pp36,
            round(avg(slp_1.fdpp36) OVER l5sls, 2) AS fd_avg_prev5_pp36,
            round(stddev(slp_1.fdpp36) OVER l5sls, 2) AS fd_std_prev5_pp36,
            round(avg(slp_1.fdpp75poss) OVER l5sls, 2) AS fd_avg_prev5_pp75poss,
            round(avg(slp_1.fdpp36) OVER l10sls, 2) AS fd_avg_prev10_pp36,
            round(stddev(slp_1.fdpp36) OVER l10sls, 2) AS fd_std_prev10_pp36,
            COALESCE(slp_1.dk_points, 0.0) AS dk_act_points,
            COALESCE(slp_1.dkpp36, 0.0) AS dk_act_pp36,
            round(avg(slp_1.dkpp36) OVER l5sls, 2) AS dk_avg_prev5_pp36,
            round(stddev(slp_1.dkpp36) OVER l5sls, 2) AS dk_std_prev5_pp36,
            round(avg(slp_1.dkpp75poss) OVER l5sls, 2) AS dk_avg_prev5_pp75poss,
            round(avg(slp_1.dkpp36) OVER l10sls, 2) AS dk_avg_prev10_pp36,
            round(stddev(slp_1.dkpp36) OVER l10sls, 2) AS dk_std_prev10_pp36
           FROM public.stat_line_points slp_1
          WHERE (slp_1.date > (slp_1.date - '30 days'::interval))
          WINDOW l3sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), l5sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING), l8sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 8 PRECEDING AND 1 PRECEDING), l10sls AS (PARTITION BY slp_1.player_id ORDER BY slp_1.date ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)
          ORDER BY slp_1.date DESC
        )
 SELECT slp.stat_line_id,
    slp.player_id,
    slp.date,
    slp.name,
    qqq.game_pace,
    qqq.act_minutes,
    qqq.act_possessions,
    qqq.avg_prev5_minutes,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird5 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid5,
        CASE
            WHEN ((qqq.avg_prev5_minutes < (5)::numeric) OR (qqq.fird10 < (qqq.date - '30 days'::interval))) THEN false
            ELSE true
        END AS valid10,
    qqq.fd_act_points,
    qqq.fd_act_pp36,
    qqq.fd_avg_prev5_pp36,
    (qqq.fd_avg_prev5_pp36 + qqq.fd_std_prev5_pp36) AS fd_ceil_prev5_pp36,
    (qqq.fd_avg_prev5_pp36 - qqq.fd_std_prev5_pp36) AS fd_floor_prev5_pp36,
    qqq.fd_avg_prev5_pp75poss,
    qqq.fd_avg_prev10_pp36,
    (qqq.fd_avg_prev10_pp36 + qqq.fd_std_prev10_pp36) AS fd_ceil_prev10_pp36,
    (qqq.fd_avg_prev10_pp36 - qqq.fd_std_prev10_pp36) AS fd_floor_prev10_pp36,
    qqq.dk_act_points,
    qqq.dk_act_pp36,
    qqq.dk_avg_prev5_pp36,
    (qqq.dk_avg_prev5_pp36 + qqq.dk_std_prev5_pp36) AS dk_ceil_prev5_pp36,
    (qqq.dk_avg_prev5_pp36 - qqq.dk_std_prev5_pp36) AS dk_floor_prev5_pp36,
    qqq.dk_avg_prev5_pp75poss,
    qqq.dk_avg_prev10_pp36,
    (qqq.dk_avg_prev10_pp36 + qqq.dk_std_prev10_pp36) AS dk_ceil_prev10_pp36,
    (qqq.dk_avg_prev10_pp36 - qqq.dk_std_prev10_pp36) AS dk_floor_prev10_pp36
   FROM (public.stat_line_points slp
     JOIN qqq ON (((slp.player_id = qqq.player_id) AND (slp.date = qqq.date))));


ALTER TABLE public.tslw OWNER TO jackschultz;

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
-- Name: games_home_team_away_team; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX games_home_team_away_team ON public.games USING btree (home_team_id, away_team_id);


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
-- Name: projections_stat_line_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX projections_stat_line_id_idx ON public.projections USING btree (stat_line_id);


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
-- Name: stat_lines_dk_salary_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_dk_salary_idx ON public.stat_lines USING btree (dk_salary);


--
-- Name: stat_lines_fd_points_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_fd_points_idx ON public.stat_lines USING btree (fd_points);


--
-- Name: stat_lines_fd_salary_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_fd_salary_idx ON public.stat_lines USING btree (fd_salary);


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

