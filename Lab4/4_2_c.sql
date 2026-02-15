CREATE OR REPLACE FUNCTION get_reliable_repeat_clients()
RETURNS TABLE(client_name VARCHAR(50)) AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT 
            cl.company_name,
            COUNT(cc.number) AS credit_count,
            BOOL_AND(cc.repaid) AS all_repaid
        FROM Client cl
        JOIN Credit_Contract cc ON cl.ID = cc.client_id
        GROUP BY cl.ID, cl.company_name
        HAVING COUNT(cc.number) > 1 AND BOOL_AND(cc.repaid) = TRUE
    LOOP
        client_name := rec.company_name;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_reliable_repeat_clients();