
-----------------------------------------------------------
-- invoices & costs(?)

-- We are going for Invoice instead of im_costs, because of
-- performance reasons. There many be many cost items, but
-- they don't usually interest us very much.

insert into im_search_object_types values (4,'im_invoice');

create or replace function im_invoice_tsearch ()
returns trigger as '
declare
	v_string	varchar;
begin
	select  coalesce(i.invoice_nr, '''') || '' '' ||
		coalesce(c.cost_nr, '''') || '' '' ||
		coalesce(c.cost_name, '''') || '' '' ||
		coalesce(c.description, '''') || '' '' ||
		coalesce(c.note, '''')
	into
		v_string
	from
		im_invoices i,
		im_costs c
	where	
		i.invoice_id = c.cost_id
		and i.invoice_id = new.invoice_id;

	perform im_search_update(new.invoice_id, ''im_invoice'', new.invoice_id, v_string);
	return new;
end;' language 'plpgsql';

CREATE TRIGGER im_invoices_tsearch_tr
BEFORE INSERT or UPDATE
ON im_invoices
FOR EACH ROW
EXECUTE PROCEDURE im_invoice_tsearch();



update im_invoices
set invoice_nr = invoice_nr;



