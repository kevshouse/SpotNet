/*"----------------------------------------------------------------------------------------"*/
/*"----Goal Here is to create the Company Node/s and associate then with their Maker     --"*/
/*"--- Nodes.                                                                           ---"*/
/*"--- 																				    ---"*/ 
/*"----------------------------------------------------------------------------------------"*/
/*"--- Kevin Anderson 25/08/2015 														---"*/
/*"--- In Support of MiniSprint Job IDs 19, 20, 21    					                ---"*/
/*"--- ETL Company and Product Data, relating companies to those products we have.      ---"*/                                								---"*/
/*"----------------------------------------------------------------------------------------"*/

/* "Get Raritan Rack iPDU Master Data" */
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/kevshouse/SpotNet/master/Power/iPduSpec.csv"
AS line
WITH  line LIMIT 1
WITH collect(line) AS dataGulpRaritan
UNWIND dataGulpRaritan AS GulpRaritan
WITH [GulpRaritan] AS coll UNWIND coll AS Makers

/* "Get Address Book Data" */
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/kevshouse/SpotNet/master/adhoc/AddressBook.csv"
AS line
WITH  Makers, line LIMIT 10
WITH collect(line) AS dataGulpAddress, Makers
UNWIND dataGulpAddress AS GulpAddress

/* "Find or Create the Company nodes" */
WITH Makers, GulpAddress
MERGE (comp:Company{Tag:GulpAddress.Tag, name:GulpAddress.Name,
tel1:GulpAddress.Tel1, tel2:GulpAddress.Tel2, fax:GulpAddress.Fax,
address1:GulpAddress.Address1, address2:GulpAddress.Address2,
address3:GulpAddress.Address3, town:GulpAddress.Town,
countyState:GulpAddress.CountyState,
code:GulpAddress.Code, country:GulpAddress.Country, email:GulpAddress.Email,
url:GulpAddress.URL})

/* "FIND or Create Maker Nodes" */
MERGE (mkr:Maker{Tag:"Maker", name:Makers.Maker, couple:Makers.Maker + Makers.Model})
WITH mkr, comp

/* "Find Companies that we have products from " */
MATCH (c:Company{name:comp.name}), (m:Maker{name:comp.name})

/* "Relate Company to Maker Nodes" */
CREATE UNIQUE (c)-[:IsA]->(m)
RETURN c, m, mkr, comp;

/*-- "The above has been tested and is working -31/08/2015----------------------------------------------" --*/
