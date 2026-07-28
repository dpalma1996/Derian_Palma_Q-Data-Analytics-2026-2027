/*

Nivell 1
Exercici 1

A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

*/

USE transactions;


SHOW TABLES;

DESCRIBE company;

DESCRIBE `transaction`;




/*

Nivell 1
Exercici 2

Utilitzant JOIN realitzaràs les següents consultes:

    Llistat dels països que estan generant vendes.
    Des de quants països es generen les vendes.
    Identifica la companyia amb la mitjana més gran de vendes.

*/

USE transactions;

#    Llistat dels països que estan generant vendes.

SELECT DISTINCT c.country AS 'países' FROM company c

JOIN transactions.`transaction` t ON t.company_id = c.id

WHERE t.declined = 0;

#    Des de quants països es generen les vendes.

SELECT COUNT(DISTINCT(c.country)) AS 'cantidad de países' FROM company c

JOIN transactions.transaction t ON t.company_id = c.id

WHERE t.declined = 0;


#    Identifica la companyia amb la mitjana més gran de vendes.

SELECT ROUND(AVG(t.amount),2) AS 'mayor media de ventas', c.company_name AS 'compañía' FROM company c

JOIN `transaction` t ON t.company_id = c.id

WHERE t.declined = 0

GROUP BY c.id, c.company_name

ORDER BY AVG(t.amount) DESC LIMIT 1;




/*


Nivell 1
Exercici 3

Utilitzant només subconsultes (sense utilitzar JOIN):

    Mostra totes les transaccions realitzades per empreses d'Alemanya.
    Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
    Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

*/

USE transactions;


#    Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT * FROM `transaction` t

WHERE t.company_id IN (
	SELECT c.id FROM company c
    
    WHERE c.country  = 'Germany'
);


#    Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT c.company_name AS 'empresas' FROM company c

WHERE c.id IN (
	SELECT t.company_id FROM `transaction` t
	WHERE t.amount > (
    	SELECT AVG(t2.amount) FROM `transaction` t2
        
        WHERE t2.declined = 0
        )
        AND t.declined = 0
);


#    Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT * FROM company c

WHERE c.id NOT IN (
	SELECT t.company_id FROM `transaction` t
	WHERE t.company_id IS NOT NULL
);




/*

Nivell 1
Exercici 4

La teva tasca és dissenyar i crear una taula anomenada "credit_card"
que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta 
i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació del document denominat 
"dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

*/

USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) NOT NULL,
    iban VARCHAR(44) NOT NULL,
    pan VARCHAR(20) NOT NULL,
    pin CHAR(4) NOT NULL,
    cvv VARCHAR(4) NOT NULL,
    expiring_date VARCHAR(8) NOT NULL,
    PRIMARY KEY (id)
);

#uso un INSERT de N1-Ex.1__dades_introduir.sql como ejemplo para hacer la Tabla
#INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) VALUES ('CcU-3400', 'IL632507629847612453498', '377471145232444', '9482', '780', '10/22/25');

#en este punto se importa el archivo: N1-Ex.1__dades_introduir.sql y finalmente:

ALTER TABLE `transaction`
ADD CONSTRAINT fk_credit_card_id 
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

DESCRIBE credit_card;
SHOW CREATE TABLE `transaction`;




/*

Nivell 1
Exercici 5

El departament de Recursos Humans ha identificat un error en el número de compte 
associat a la targeta de crèdit amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
Recorda mostrar que el canvi es va realitzar.

*/

USE transactions;

SELECT * FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT * FROM credit_card
WHERE id = 'CcU-2938';




/*

Nivell 1
Exercici 6

En la taula "transaction" ingressa una nova transacció amb la següent informació:


Id 

108B1D1D-5B23-A76C-55EF-C568E49A99DD 

credit_card_id 

CcU-9999 

company_id 

b-9999 

user_id 

9999 

lat 

829.999 

longitude 

-117.999 

amount 

111.11 

declined 

0 
          

*/

USE transactions;


# primero creamos una compañía con ese id para poder insertar la transacción
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'NA', '99 99 99 99 99', 'mail@mail.cm', 'world', 'https://');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, '829.999', '-117.999', '2018-12-12 08:05:17', '111.11', '0');
# user_id es INT




/*

Nivell 1
Exercici 7

Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
Recorda mostrar el canvi realitzat.

*/

USE transactions;


ALTER TABLE credit_card 
DROP COLUMN pan;

DESCRIBE credit_card;




/*

Nivell 1
Exercici 8

Descarrega els arxius CSV que trobaràs a l'apartat de recursos:

    american_users.csv
    european_users.csv
    companies.csv
    credit_cards.csv
    transactions.csv

Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
almenys 4 taules de les quals puguis realitzar les següents consultes:
La taula de products.csv l'utilitzarem més endavant.

*/

### Creación de la base de datos

DROP DATABASE IF EXISTS star;

CREATE DATABASE star;

USE star;

SELECT DATABASE();

### Creación de las tablas

CREATE TABLE companies (
    company_id VARCHAR(20) NOT NULL,
    company_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255),
    merchant_category VARCHAR(100),
    merchant_price_position VARCHAR(50),
    CONSTRAINT pk_companies PRIMARY KEY (company_id)
);

CREATE TABLE credit_cards (
    id VARCHAR(20) NOT NULL,
    user_id INT,
    iban VARCHAR(40),
    pan VARCHAR(20),
    pin VARCHAR(10),
    cvv VARCHAR(10),
    track1 VARCHAR(150),
    track2 VARCHAR(150),
    expiring_date VARCHAR(10),
    card_type VARCHAR(50),
    card_renewal_flag TINYINT,
    CONSTRAINT pk_credit_cards PRIMARY KEY (id)
);

CREATE TABLE american_users (
    id INT NOT NULL,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(50),
    CONSTRAINT pk_american_users PRIMARY KEY (id)
);

CREATE TABLE european_users (
    id INT NOT NULL,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(50),
    CONSTRAINT pk_european_users PRIMARY KEY (id)
);

CREATE TABLE transactions (
    id CHAR(36) NOT NULL,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT,
    product_ids VARCHAR(255),
    user_id INT,
    lat DOUBLE,
    longitude DOUBLE,
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    channel VARCHAR(30),
    campaign_id VARCHAR(50),
    device_type VARCHAR(30),
    is_international TINYINT,
    decline_reason VARCHAR(100),
    distance_km DECIMAL(10,2),
    CONSTRAINT pk_transactions PRIMARY KEY (id)
);

SHOW TABLES;

DESCRIBE american_users;

DESCRIBE european_users;

SELECT COUNT(*) AS total_american_users
FROM american_users;

SELECT COUNT(*) AS total_european_users
FROM european_users;

SELECT
    au.id,
    COUNT(*) AS coincidencias
FROM american_users au
JOIN european_users eu
    ON au.id = eu.id
GROUP BY au.id;

DROP TABLE IF EXISTS users;

CREATE TABLE users AS

SELECT
    *,
    'American' AS user_origin
FROM american_users

UNION ALL

SELECT
    *,
    'European' AS user_origin
FROM european_users;


SELECT COUNT(*) AS total_users
FROM users;

ALTER TABLE users
ADD CONSTRAINT pk_users PRIMARY KEY (id);

ALTER TABLE credit_cards
ADD CONSTRAINT fk_credit_cards_users
FOREIGN KEY (user_id)
REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id)
REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (business_id)
REFERENCES companies(company_id);

DROP TABLE american_users;
DROP TABLE european_users;




/*


Nivell 1
Exercici 9

Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

*/

USE star;


SELECT u.name, u.surname, t.total_transactions FROM users u

JOIN (
    SELECT
        t.user_id,
        COUNT(*) AS total_transactions
    FROM transactions AS t
    GROUP BY t.user_id
    HAVING COUNT(*) > 80
) AS t
    ON u.id = t.user_id;




/*

Nivell 1
Exercici 10

Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

*/

USE star;


SELECT cc.iban, ROUND(AVG(t.amount),2) AS "media de amount" FROM transactions t
JOIN credit_cards cc
ON t.card_id = cc.id
JOIN companies c
ON c.company_id = t.business_id

WHERE c.company_name = 'Donec Ltd' AND declined = 0

GROUP BY cc.iban;




/*

Nivell 2
Exercici 1

Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.

*/

USE star;


SELECT DATE(t.`timestamp`) AS 'fechas', ROUND(SUM(t.amount),2) 'total de las ventas' FROM transactions t

WHERE t.declined = 0 

GROUP BY DATE(t.`timestamp`)

ORDER BY 'total de las ventas' DESC
LIMIT 5;




/*

Nivell 2
Exercici 2

Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor 
comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
Ordena els resultats de major a menor quantitat.

*/

USE star;


SELECT c.company_name AS 'empresas', c.phone AS 'teléfono', c.country AS 'país', DATE(t.`timestamp`) AS 'fecha', t.amount AS 'monto'
FROM companies c
JOIN transactions t
ON t.business_id = c.company_id

WHERE (t.amount BETWEEN 350 AND 400) AND
DATE(t.`timestamp`) IN ('2015-04-29', '2018-07-20', '2024-03-13') AND
t.declined = 0

ORDER BY 'monto' DESC;




/*

Nivell 2
Exercici 3

Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen igual o més de 400 transaccions o menys.

*/

USE star;

SELECT c.company_name AS 'empresas', COUNT(t.id) AS 'cantidad de transacciones',
CASE
  WHEN COUNT(t.id) >= 400 THEN 'Igual o Más de 400 transacciones'
  ELSE 'Menos de 400 transacciones'
END AS Categoria

FROM transactions t

JOIN companies c
ON c.company_id = t.business_id

GROUP BY c.company_id, c.company_name;




/*

Nivell 2
Exercici 4

Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

*/

USE star;

# Verificar que el registro existe
SELECT * FROM transactions WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# Verificar que el registro se eliminó
SELECT * FROM transactions WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';




/*

Nivell 2
Exercici 5

La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

*/

USE star;

DROP VIEW IF EXISTS VistaMarketing;

CREATE VIEW VistaMarketing AS

SELECT
    c.company_name AS 'Nombre de la compañía',
    c.phone AS 'Teléfono de contacto',
    c.country AS 'País de residencia',
    ROUND(AVG(t.amount),2) AS 'Media de compra'

FROM companies c

JOIN transactions t
ON c.company_id = t.business_id

WHERE t.declined = 0

GROUP BY c.company_id, c.company_name, c.phone, c.country;
    
    /* Mostrar la vista */

SELECT *
FROM VistaMarketing

ORDER BY 'Media de compra' DESC;