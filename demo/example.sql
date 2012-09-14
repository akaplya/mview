USE mview_demo;

SELECT c.customer_id, MAX(customer_name) AS customer_name, SUM(payment) AS payment
FROM mview_demo.customer AS c
INNER JOIN mview_demo.customer_payment AS cp ON cp.customer_id = c.customer_id
GROUP BY c.customer_id;

SELECT c.customer_id, MAX(customer_name) AS customer_name, SUM(payment) AS payment
FROM mview_demo.customer AS c
INNER JOIN mview_demo.customer_payment AS cp ON cp.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING SUM(payment) > 100;


CALL mview.create(SCHEMA(), 'customer_balance',
 'SELECT c.customer_id, MAX(customer_name) AS customer_name, SUM(payment) AS payment
  FROM mview_demo.customer AS c
  INNER JOIN mview_demo.customer_payment AS cp ON cp.customer_id = c.customer_id
  GROUP BY c.customer_id');
  
SELECT * FROM mview.metadata;

SELECT * FROM mview_demo.vw_customer_balance;

SELECT * FROM mview_demo.customer_balance;

ALTER TABLE mview_demo.customer_balance
  ADD UNIQUE KEY uix_mw_customer_balance_customer_id (customer_id);

ALTER TABLE mview_demo.customer_balance
  ADD KEY uix_mw_customer_balance_payment (payment);

SELECT * 
FROM mview_demo.customer_balance 
WHERE payment > 100;

INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (2, 46.15);
INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (3, -17.02);
INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (4, 13.07);
INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (5, 55.15);

CALL mview.refresh(SCHEMA(), 'customer_balance');

CALL mview.refresh_safe(SCHEMA(), 'customer_balance');

CALL mview.set_rule_column(SCHEMA(), 'customer_balance', 'customer_id');

INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (4, 55.11);
INSERT INTO mview_demo.customer_payment (customer_id, payment) VALUES (4, 43.07);

CALL mview.refresh_row(SCHEMA(), 'customer_balance', 4);

CALL mview.enable_changelog(SCHEMA(), 'customer_balance', 'customer_payment', 'customer_id');

CALL mview.get_changelog_triggers_body(SCHEMA(), 'customer_payment');

use mview_demo;
CALL mview.refresh_changelog(SCHEMA(), 'customer_balance');

SELECT * 
FROM mview_demo.customer_balance;

SELECT * 
FROM mview_demo.vw_customer_balance;


SELECT *
FROM mview_demo.customer_balance_changelog;

CALL mview.drop(SCHEMA(), 'customer_balance');

DROP TABLE mview_demo.customer_balance_changelog;
