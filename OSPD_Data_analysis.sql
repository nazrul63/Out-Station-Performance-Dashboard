-- All Station's Performance 
select tmp1.*, 
    ROW_number() over (order by tmp1.avg_pax_total ASC) as serial_pax_factor, 
    ROW_number() over (order by tmp1.avg_otp asc) as serial_otp, 
    ROW_number() over (order by tmp1.ex_baggage_rev_total ASC) as serial_ex_bag, 
    ROW_number() over (order by tmp1.ttl_cargo ASC) as serial_cargo
from (
        select 
            substr(sector,1,3) as sector, 
            avg(pax_load_factor_total) as avg_pax_total, 
            avg(pax_load_factor_business) as avg_pax_business, 
            avg(pax_load_factor_p_economy) as avg_pax_p_economy, 
            avg(pax_load_factor_economy) as avg_pax_economy,  
            sum(travelled_business) as sum_b_pax, 
            sum(travelled_p_economy) as sum_p_economy_pax, 
            sum(travelled_economy) as sum_economy_pax, 
            cast(avg(case when otp_quantity<= 15 then 100 else 0 end ) as decimal (9,2)) as avg_otp,
            sum(ex_baggage_quantity) as ttl_ex_bag,  
            sum(ex_baggage_revenue_bd) as ex_baggage_rev_total, 
            sum(cargo_quantity) as ttl_cargo,
            ROW_NUMBER() OVER (order by AVG(pax_load_factor_total) ASC, avg(otp_quantity) desc, SUM(ex_baggage_quantity) asc, SUM(cargo_quantity) asc) as serial_overall
        from `table_name` 
        where flight_status = 'FLIGHT' and flight_date between '$startDate' AND '$endDate' 
        group by substr(sector,1,3)
    ) tmp1


-- Overall Performance of Stations
select 
    tmp1.total_sectors as total_sectors, 
    sum(tmp1.flights_per_sector) as total_flights,
    (sum(tmp1.sum_b_pax + tmp1.sum_p_economy_pax + tmp1.sum_economy_pax)/sum(tmp1.sum_c_b_pax + tmp1.sum_c_p_economy_pax + tmp1.sum_c_economy_pax))*100 as overall_avg_pax_ratio, 
    (sum(tmp1.sum_b_pax)/sum(tmp1.sum_c_b_pax))*100 as overall_avg_pax_business, 
    (sum(tmp1.sum_p_economy_pax)/sum(tmp1.sum_c_p_economy_pax))*100 as overall_avg_pax_p_economy, 
    (sum(tmp1.sum_economy_pax)/sum(tmp1.sum_c_economy_pax))*100 as overall_avg_pax_economy, 
    sum(tmp1.sum_b_pax + tmp1.sum_p_economy_pax + tmp1.sum_economy_pax) as overall_sum_pax, 
    sum(tmp1.sum_b_pax) as overall_sum_pax_business, 
    sum(tmp1.sum_p_economy_pax) as overall_sum_pax_p_economy, 
    sum(tmp1.sum_economy_pax) as overall_sum_pax_economy, 
    sum(tmp1.sum_c_b_pax + tmp1.sum_c_p_economy_pax + tmp1.sum_c_economy_pax) as overall_sum_c_pax, 
    sum(tmp1.sum_c_b_pax) as overall_sum_c_pax_business, 
    sum(tmp1.sum_c_p_economy_pax) as overall_sum_c_pax_p_economy, 
    sum(tmp1.sum_c_economy_pax) as overall_sum_c_pax_economy, 
    avg(tmp1.avg_otp) as overall_avg_otp,
    sum(tmp1.ttl_ex_bag) as overall_ex_bag_quantity, 
    sum(tmp1.ex_baggage_rev_total) as overall_ex_bag_revenue, 
    sum(tmp1.ttl_cargo) as overall_cargo_quantity
    from (
            select 
                substr(sector,1,3) as sector,
                sum(travelled_business) as sum_b_pax, 
                sum(travelled_p_economy) as sum_p_economy_pax, 
                sum(travelled_economy) as sum_economy_pax, 
                sum(capacity_business) as sum_c_b_pax, 
                sum(capacity_p_economy) as sum_c_p_economy_pax, 
                sum(capacity_economy) as sum_c_economy_pax, 
                cast(avg(case when otp_quantity<= 15 then 100 else 0 end ) as decimal (9,2)) as avg_otp,
                sum(case when otp_quantity<= 15 then 100 else 0 end ) as sum_otp,
                count(*) as flights_per_sector,
                count(*) over () as total_sectors,
                sum(ex_baggage_quantity) as ttl_ex_bag,  
                sum(ex_baggage_revenue_bd) as ex_baggage_rev_total, 
                sum(cargo_quantity) as ttl_cargo,
                ROW_NUMBER() OVER (order by AVG(pax_load_factor_total) ASC, avg(otp_quantity) desc, SUM(ex_baggage_quantity) asc, SUM(cargo_quantity) asc) as serial_overall
            from `table_name` 
            where flight_status = 'FLIGHT' and flight_date between '$startDate' AND '$endDate' 
            group by substr(sector,1,3)
        ) tmp1 group by tmp1.total_sectors

-- Station Wise Details
SELECT 
    substr(sector,1,3) as sector, 
    flight_date,
    pax_load_factor_business, 
    pax_load_factor_p_economy, 
    pax_load_factor_economy, 
    pax_load_factor_total,
    otp_quantity, 
    ex_baggage_quantity, 
    ex_baggage_revenue_bd, 
    cargo_quantity,
    otp_status, 
    otp_remarks, 
    remarks
FROM `table_name` 
where flight_status = 'FLIGHT' and flight_date between '$startDate' AND '$endDate'
GROUP BY 
    substr(sector,1,3), 
    flight_date,
    pax_load_factor_business, 
    pax_load_factor_p_economy, 
    pax_load_factor_economy, 
    pax_load_factor_total,
    otp_quantity, 
    ex_baggage_quantity, 
    ex_baggage_revenue_bd, 
    cargo_quantity,
    otp_status, 
    otp_remarks, 
    remarks