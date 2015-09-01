/*"-----------------------------------------------------------------------------------------------"*/
/*"----Goal Here is to create the Company Node/s and associate then with their Maker   		   ---"*/
/*"--- and Master                                                                      		   ---"*/
/*"--- 				       																	   ---"*/ 
/*"-----------------------------------------------------------------------------------------------"*/
/*"--- Kevin Anderson 01/09/2015 	                            							   ---"*/
/*"--- In Support of MiniSprint Job IDs 19, 20, 21    				                		   ---"*/                              						
/*"-----------------------------------------------------------------------------------------------"*/
/*--- "Cypher to create Rack Master Nodes and Relate them to their Maker Nodes."	 			---*/
/*--- "Constraints need to be set on all Master Nodes. Therefore there is a "		 			---*/
/*--- " need for something about the node which is essentially unique, suggest Model + Maker."  ---*/
/*"-----------------------------------------------------------------------------------------------"*/
CREATE CONSTRAINT ON (mn:Master) ASSERT mn.idMaster IS UNIQUE;
CREATE CONSTRAINT ON (ma:Maker) ASSERT ma.couple IS UNIQUE;

/* "Get IBM Rack Master Data" *
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/kevshouse/SpotNet/master/RackHardwareTypes/IbmRack7014-B42.csv"
AS line
WITH line LIMIT 10
WITH collect(line) AS dataGulpIBM
UNWIND dataGulpIBM AS GulpIBM

/* "Get Oracle Rack Master Data" */
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/kevshouse/SpotNet/master/RackHardwareTypes/OracleSunRackIIRack.csv"
AS line
WITH  GulpIBM, line LIMIT 10
WITH collect(line) AS dataGulpOracle, GulpIBM
UNWIND dataGulpOracle AS GulpOracle
/* "Squish the two collections together" */
WITH [GulpOracle,GulpIBM] AS coll UNWIND coll AS Makers

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
WITH mkr, comp, Makers

/* "Find Companies that we have products from " */
MATCH (co:Company{name:comp.name}), (ma:Maker{name:comp.name})

/* "Relate Company to Maker Nodes" */
CREATE UNIQUE (co)-[:IsA]->(ma)

/* "Now to make Master Nodes" */
WITH mkr, comp, co, ma, Makers AS Masters

WITH Masters.Maker + Masters.Model AS idMaster, Masters, co
/* "FIND or Create Master Nodes" */
MERGE (mst:Master{Tag:Masters.Tag, name:Masters.Maker, idMaster:idMaster, DocURI:Masters.DocURI})

/*-- "locate their maker nodes and relate them." --*/
WITH mst, Masters, idMaster, co
// RETURN idMaster
MATCH (mkr:Maker{couple:idMaster})
CREATE UNIQUE (mkr)-[:Makes]->(mst)
RETURN mst, mkr, co