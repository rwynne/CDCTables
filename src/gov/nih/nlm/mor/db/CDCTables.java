package gov.nih.nlm.mor.db;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import javax.net.ssl.HttpsURLConnection;

import org.json.JSONArray;
import org.json.JSONObject;

import gov.nih.nlm.mor.db.rxnorm.Concept;
import gov.nih.nlm.mor.db.rxnorm.ConceptRelationship;
import gov.nih.nlm.mor.db.rxnorm.ConceptType;
import gov.nih.nlm.mor.db.rxnorm.Source;
import gov.nih.nlm.mor.db.rxnorm.Term;
import gov.nih.nlm.mor.db.rxnorm.TermRelationship;
import gov.nih.nlm.mor.db.rxnorm.TermType;
import gov.nih.nlm.mor.db.table.AuthoritativeSourceTable;
import gov.nih.nlm.mor.db.table.Concept2ConceptTable;
import gov.nih.nlm.mor.db.table.ConceptTable;
import gov.nih.nlm.mor.db.table.ConceptTypeTable;
import gov.nih.nlm.mor.db.table.Term2TermTable;
import gov.nih.nlm.mor.db.table.TermTable;
import gov.nih.nlm.mor.db.table.TermTypeTable;

public class CDCTables {
	
	public AuthoritativeSourceTable authoritativeSourceTable = new AuthoritativeSourceTable();
	public Concept2ConceptTable concept2ConceptTable = new Concept2ConceptTable();
	public ConceptTable conceptTable = new ConceptTable();
	public ConceptTypeTable conceptTypeTable = new ConceptTypeTable();
	public Term2TermTable term2TermTable = new Term2TermTable();
	public TermTable termTable = new TermTable();
	public TermTypeTable termTypeTable = new TermTypeTable();
	
	private PrintWriter authoritativeSourceFile = null;
	private PrintWriter conceptTypeFile = null;
	private PrintWriter termTypeFile = null;
	private PrintWriter termFile = null;
	private PrintWriter conceptFile = null;
	private PrintWriter term2termFile = null;
	private PrintWriter concept2conceptFile = null;
	
	private final String baseUrl = "https://rxnav.nlm.nih.gov/REST";
	private final String allConceptsUrl = "https://rxnav.nlm.nih.gov/REST/allconcepts.json?tty=IN";
	private final String allClassesUrl = "https://rxnav.nlm.nih.gov/REST/rxclass/allClasses.json?classTypes=ATC1-4";
	
	private HashMap<String, ArrayList<String>> rxcui2Misspellings = new HashMap<String, ArrayList<String>>();
	private HashMap<String, ArrayList<String>> rxcui2DrugTCodes = new HashMap<String, ArrayList<String>>();
	private HashMap<String, String> tcode2Description = new HashMap<String, String>();
	
	private HashMap<String, String> sourceMap = new HashMap<String, String>();
	private HashMap<String, String> termTypeMap = new HashMap<String, String>();
	private HashMap<String, String> classTypeMap = new HashMap<String, String>();
	
	private Integer codeGenerator = 0;
	
	public static void main(String[] args) {
		CDCTables tables = new CDCTables();
		long start = System.currentTimeMillis();				
		tables.configure();
		tables.gather();
		tables.serialize();
		tables.cleanup();
		System.out.println("Finished data serialization in " + (System.currentTimeMillis() - start) / 1000 + " seconds.");		
	}
	
	private void configure() {
		//We are going to hardcode these filenames to ensure
		//deliverable consistency to CDC
		String authoritativePath = "./authoritative-source.txt";
		String conceptTypePath = "./concept-type.txt";
		String termTypePath = "./term-type.txt";
		String termPath = "./term.txt";
		String conceptPath = "./concept.txt";
		String term2termPath = "./term-term.txt";
		String concept2conceptPath = "./concept-concept.txt";
		
		String cui2MisspellingsPath = "./config/filtered_RxNorm-msp.txt";
		String rx2ICDPath = "./config/rx2ICD.txt";

		readFile(cui2MisspellingsPath, "spell");
		readFile(rx2ICDPath, "rx2icd");
		
		try {
			authoritativeSourceFile = new PrintWriter(new File(authoritativePath));
			conceptTypeFile = new PrintWriter(new File(conceptTypePath));
			termTypeFile = new PrintWriter(new File(termTypePath));
			termFile = new PrintWriter(new File(termPath));
			conceptFile = new PrintWriter(new File(conceptPath));
			term2termFile = new PrintWriter(new File(term2termPath));
			concept2conceptFile = new PrintWriter(new File(concept2conceptPath));
		}
		catch(Exception e) {
			System.out.print("There was an error trying to create one of the table files.");
			e.printStackTrace();
		}
	}
		
	private void readFile(String filename, String type) {
		FileReader file = null;
		BufferedReader buff = null;
		try {
			file = new FileReader(filename);
			buff = new BufferedReader(file);
			boolean eof = false;
			int colIndex = -1;
			while (!eof) {
				String line = buff.readLine();
				if (line == null)
					eof = true;
				else {	
					if( line != null && line.contains("|") ) {
						String[] values = line.split("\\|", -1);

						switch(type)
						{
							case "spell":
								String rxname = values[0];
								String rxcui = values[1];
								String misspell = values[2];
								setMisspellingMap(rxname, rxcui, misspell);
								break;
							case "rx2icd":
								String rxname1 = values[0];
								String rxcui1 = values[1];
								String tcode = values[2];
								String tdesc = values[3];
								setDrugCodesMap(rxname1, rxcui1, tcode, tdesc);
								break;
							default:
								System.err.println("The following config file was unexpected: " + filename);
						}
					}
					else {
						System.err.println("No Property configured for configuration index " + colIndex);
						System.err.println("Exiting");
						System.exit(-1);
					}						
				}
			}
//			//			for( int i=0; i < columns.size(); i++ ) {
//			//				columns.elementAt(i).print();
//			//			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			// Closing the streams
			try {
				buff.close();
				file.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}				
	}
	
	private void setMisspellingMap(String rxname, String rxcui, String misspell) {
		if( rxcui2Misspellings.containsKey(rxcui) ) {
			ArrayList<String> list = rxcui2Misspellings.get(rxcui);
			if( !list.contains(misspell) ) {
				list.add(misspell);
				rxcui2Misspellings.put(rxcui, list);
			}
		}
		else {
			ArrayList<String> list = new ArrayList<String>();
			list.add(misspell);
			rxcui2Misspellings.put(rxcui, list);
		}
	}
	
	private void setDrugCodesMap(String rxname, String rxcui, String tcode, String tdesc) {
		if( !tcode2Description.containsKey(tcode) && !tdesc.isEmpty() ) {
			tcode2Description.put(tcode, tdesc);
		}
		
		if( !rxcui2DrugTCodes.containsKey(rxcui) && !tcode.isEmpty()) {
			ArrayList<String> list = new ArrayList<String>();
			list.add(tcode);
			rxcui2DrugTCodes.put(rxcui, list);
		}
		else if( rxcui2DrugTCodes.containsKey(rxcui) && !tcode.isEmpty() ) {
			ArrayList<String> list = rxcui2DrugTCodes.get(rxcui);
			list.add(tcode);
			rxcui2DrugTCodes.put(rxcui, list);
		}
	}
	
	private void addMisspellings() {
		for( String rxcui : rxcui2Misspellings.keySet() ) {
			ArrayList<String> misList = rxcui2Misspellings.get(rxcui);
			for( String misTerm : misList ) {
				Term term = new Term();
				term.setId(++codeGenerator);
				term.setTty(termTypeMap.get("MSP"));
				term.setName(misTerm);
				term.setSource("Misspelling");
				term.setSourceId("");
				
				termTable.add(term);
				
				Integer misId = codeGenerator;
				
				if( termTable.hasTerm(rxcui, termTypeMap.get("IN"), sourceMap.get("RxNorm")) ) {
					Term t = termTable.getTerm(rxcui, termTypeMap.get("IN"), sourceMap.get("RxNorm"));
					
					TermRelationship termRel = new TermRelationship();
					termRel.setId(++codeGenerator);
					termRel.setTermId1(misId);
					termRel.setRelationship(termTypeMap.get("MSP"));
					termRel.setTermId2(t.getId());
					
					term2TermTable.add(termRel);
				}

			}
		}
		
	}
	
	private void addTCodes() {
		for( String rxcui : rxcui2DrugTCodes.keySet() ) {
			ArrayList<String> tList = rxcui2DrugTCodes.get(rxcui);
			for( String tcode : tList ) {
				if( tcode2Description.containsKey(tcode) ) {
					String name = tcode2Description.get(tcode);
					
					Term term = new Term();			
					Concept concept = new Concept();
					if( !termTable.hasTerm(tcode, "", sourceMap.get("ICD")) &&
						!conceptTable.hasConcept(tcode, sourceMap.get("ICD"))) {
						term.setId(++codeGenerator);
						term.setName(name);
						term.setSource(sourceMap.get("ICD"));
						term.setSourceId(tcode);
						term.setTty("");
						concept.setConceptId(++codeGenerator);
						concept.setPreferredTermId(term.getId());
						concept.setClassType(classTypeMap.get("Class"));
						concept.setSource(sourceMap.get("ICD"));
						concept.setSourceId(tcode);

						conceptTable.add(concept);
						termTable.add(term);
					}
					
					Concept rxConcept = conceptTable.getConcept(rxcui, sourceMap.get("RxNorm"));
					if( rxConcept != null ) {
						Integer rxConceptId = rxConcept.getConceptId();
						Integer icdId = codeGenerator;
												
						ConceptRelationship conRel = new ConceptRelationship();
						conRel.setId(++codeGenerator);
						conRel.setConceptId1(rxConceptId);
						conRel.setRelationship("memberof");
						conRel.setConceptId2(icdId);
						
						concept2ConceptTable.add(conRel);
					}
					
				}
			}
		}
		
	}

	
	private void gather() {
		JSONObject allConcepts = null;
		JSONObject allClasses = null;
		
		try {
			allConcepts = getresult(allConceptsUrl);
			allClasses = getresult(allClassesUrl);			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		setAuthoritativeSourceTable();
		setConceptTypeTable();
		setTermTypeTable();
		
		System.out.println("allClassesUrl");
		if( allClasses != null ) {
			if( !allClasses.isNull("rxclassMinConceptList") ) {
				JSONObject rxclassMinConceptList = (JSONObject) allClasses.get("rxclassMinConceptList");
				if( !rxclassMinConceptList.isNull("rxclassMinConcept") ) {
					JSONArray rxclassMinConceptArray = (JSONArray) rxclassMinConceptList.get("rxclassMinConcept");
					for( int i = 0; i < rxclassMinConceptArray.length(); i++ ) {
						JSONObject atcClass = (JSONObject) rxclassMinConceptArray.get(i);
						
						//Get the class name and id, then proceed to collect all edges
						String classId = atcClass.get("classId").toString();
						String className = atcClass.get("className").toString();
						
						Term term = new Term();
						term.setId(++codeGenerator);
						term.setName(className);
						term.setSourceId(classId);
						term.setSource(sourceMap.get("ATC"));
						term.setTty("");
						
						Concept concept = new Concept();
						concept.setConceptId(++codeGenerator);
						concept.setPreferredTermId(term.getId());						
						concept.setClassType(classTypeMap.get("Class"));
						concept.setSource(sourceMap.get("ATC"));
						concept.setSourceId(classId);
						
						termTable.add(term);
						conceptTable.add(concept);					
					}
				}
			}
		}
		
		//collect edges for each concept
		//https://rxnav.nlm.nih.gov/REST/rxclass/classGraph.json?classId=A&source=ATC1-4 - this is the only call I know of to get the edges, and unfortunately no way to specify direct
		ArrayList<Concept> conceptList = conceptTable.getConceptsOfSource(sourceMap.get("ATC"));
		for( int i=0; i < conceptList.size(); i++ ) {
			Concept concept = conceptList.get(i);
			//pickup here
			String graphUrl = "https://rxnav.nlm.nih.gov/REST/rxclass/classGraph.json?classId=" + concept.getSourceId() + "&source=ATC1-4";
			JSONObject allEdges = null;
			
			try {
				allEdges = getresult(graphUrl);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if( allEdges != null ) {
				if( !allEdges.isNull("rxclassGraph") ) {
					JSONObject rxclassGraph = (JSONObject) allEdges.get("rxclassGraph");
					if( !rxclassGraph.isNull("rxclassEdge") ) {
//						System.out.println(graphUrl);
						JSONArray edgeArray = null;
						if( rxclassGraph.get("rxclassEdge") instanceof JSONArray ) {
							edgeArray = (JSONArray) rxclassGraph.get("rxclassEdge");
						}
						else if(rxclassGraph.get("rxclassEdge") instanceof JSONObject) {
							edgeArray = new JSONArray();
							edgeArray.put((JSONObject) rxclassGraph.get("rxclassEdge"));
						}
						for( int j=0; j < edgeArray.length(); j++ ) {
							JSONObject edge = (JSONObject) edgeArray.get(j);
							String classId1 = edge.get("classId1").toString();
							String classId2 = edge.get("classId2").toString();
							Integer classIndex1 = null;
							Integer classIndex2 = null;
							if( conceptTable.hasConcept(classId1, sourceMap.get("ATC")) ) {
								Concept c = conceptTable.getConcept(classId1, sourceMap.get("ATC"));
								if( c != null) {
									classIndex1 = c.getConceptId();
								}								
							}
							if( conceptTable.hasConcept(classId2, sourceMap.get("ATC")) ) {
								Concept c = conceptTable.getConcept(classId2, sourceMap.get("ATC"));
								if( c != null) {
									classIndex2 = c.getConceptId();
								}
							}
							if( !concept2ConceptTable.containsPair(classIndex1, "isa", classIndex2) && classIndex1 != null && classIndex2 != null) {
								ConceptRelationship conRel = new ConceptRelationship();
								conRel.setId(++codeGenerator);
								conRel.setConceptId1(classIndex1);
								conRel.setRelationship("isa");
								conRel.setConceptId2(classIndex2);
								concept2ConceptTable.add(conRel);
							}
						}
					}
					
				}
			}
		}
		
		System.out.println(allConceptsUrl);
		if( allConcepts != null ) {
			JSONObject group = null;
			JSONArray minConceptArray = null;		
			
			group = (JSONObject) allConcepts.get("minConceptGroup");
			minConceptArray = (JSONArray) group.get("minConcept");
			for(int i = 0; i < minConceptArray.length(); i++ ) {
//				HashMap<Concept, ArrayList<Term>> concept2Terms = new HashMap<Concept, ArrayList<Term>>();
				
				if( i != 0 && i % 1000 == 0 ) {
					System.out.println("Processed " + i + " INs of " + minConceptArray.length());
				}
				
				JSONObject minConcept = (JSONObject) minConceptArray.get(i);
				
				String rxcui = minConcept.get("rxcui").toString();
				String name = minConcept.get("name").toString();
				String type = minConcept.get("tty").toString();				
				
				Concept concept = new Concept();
				Term term = new Term();

				term.setId(++codeGenerator);
				Integer preferredTermId = codeGenerator;				
				term.setName(name);
				term.setTty(termTypeMap.get(type)); //this could be IN instead
				term.setSourceId(rxcui);
				term.setSource(sourceMap.get("RxNorm"));				
				
		
				concept.setConceptId(++codeGenerator);
				concept.setSource(sourceMap.get("RxNorm"));
				concept.setSourceId(rxcui);
				concept.setClassType(classTypeMap.get("Substance"));
				concept.setPreferredTermId(preferredTermId);				
				
//				Integer conceptId = codeGenerator;
				
				conceptTable.add(concept);
				termTable.add(term);
				
			
				JSONObject allProperties = null;
				JSONObject allRelated = null;
				JSONObject possibleMembers = null;;
				
				try {
					allRelated = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allrelated.json");
					allProperties = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allProperties.json?prop=all");		
					possibleMembers = getresult("https://rxnav.nlm.nih.gov/REST/rxclass/class/byRxcui.json?rxcui=" + rxcui + "&relaSource=ATC");				
				} catch(IOException e) {
					e.printStackTrace();
				}
				
//				System.out.println("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allrelated.json");
				if( allRelated != null ) {
					JSONObject allRelatedGroup = (JSONObject) allRelated.get("allRelatedGroup");
					JSONArray conceptGroup = (JSONArray) allRelatedGroup.get("conceptGroup");
					
					for( int j = 0; j < conceptGroup.length(); j++ ) {
						
						JSONObject relatedConcept = (JSONObject) conceptGroup.get(j);
						String relatedType = relatedConcept.get("tty").toString();
						
						if( (relatedType.equals("PIN") || relatedType.equals("BN")) && !relatedConcept.isNull("conceptProperties") ) {
							
								JSONArray relatedProperties = (JSONArray) relatedConcept.get("conceptProperties");
								JSONObject soleProperty = (JSONObject) relatedProperties.get(0);
								Term relatedTerm = new Term();
								
								String relatedCuiString = soleProperty.get("rxcui").toString();
								String relatedName = soleProperty.get("name").toString();
								
								relatedTerm.setId(++codeGenerator);
								relatedTerm.setName(relatedName);
								relatedTerm.setTty(termTypeMap.get(relatedType));
								relatedTerm.setSourceId(relatedCuiString);
								relatedTerm.setSource(sourceMap.get("RxNorm"));
								
								termTable.add(relatedTerm);
								
								Integer termId = codeGenerator;
								
								TermRelationship termRel = new TermRelationship();
								termRel.setId(++codeGenerator);
								termRel.setTermId1(termId);
								termRel.setTermId2(preferredTermId);
								termRel.setRelationship(termTypeMap.get(relatedType));
								
								term2TermTable.add(termRel);
								
						}
							
					}
						
				}
				
				//what are we looking for here?  Synonyms, then maybe UNIIs
				//so far
//				System.out.println("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allProperties.json?prop=all");
				if( allProperties != null ) {
					JSONObject propConceptGroup = (JSONObject) allProperties.get("propConceptGroup");
					JSONArray propConcept = (JSONArray) propConceptGroup.get("propConcept");
					
					for( int j = 0; j < propConcept.length(); j++ ) {
						
						JSONObject prop = (JSONObject) propConcept.get(j);
						String propName = prop.getString("propName");
						if( propName.equals("RxNorm Synonym") ) {
							Term synonym = new Term();
							synonym.setId(++codeGenerator);					
							synonym.setName(prop.get("propValue").toString());
							synonym.setTty(termTypeMap.get("SY"));
							synonym.setSourceId(rxcui);
							synonym.setSource(sourceMap.get("RxNorm"));
							
							termTable.add(synonym);
							
							Integer synonymId = codeGenerator;							
							
							TermRelationship termRel = new TermRelationship();
							termRel.setId(++codeGenerator);
							termRel.setTermId1(synonymId);							
							termRel.setTermId2(preferredTermId);
							termRel.setRelationship(termTypeMap.get("SY"));
							
							term2TermTable.add(termRel);
							
						}
// TBD
//						else if( propName.equals("UNII_CODE") ) {
//							Term uniiCode = new Term();
//							uniiCode.setId(++codeGenerator);
//							uniiCode.setName(prop.getString("propValue").toString());
//							uniiCode.setTty("UNII_CODE");
//							
//							
//						}							
					}
					
				}
				
//				System.out.println("https://rxnav.nlm.nih.gov/REST/rxclass/class/byRxcui.json?rxcui=" + rxcui + "&relaSource=ATC");	
				if( possibleMembers != null ) {
					if( !possibleMembers.isNull("rxclassDrugInfoList") ) {
						JSONObject rxclassdrugInfoList = (JSONObject) possibleMembers.get("rxclassDrugInfoList");
						JSONArray drugInfoList = (JSONArray) rxclassdrugInfoList.get("rxclassDrugInfo");					
						for( int j=0; j < drugInfoList.length(); j++ ) {
							JSONObject rxclassDrugInfo = (JSONObject) drugInfoList.get(j);
							if( !rxclassDrugInfo.isNull("rxclassMinConceptItem") ) {
								JSONObject rxclassMinConceptItem = (JSONObject) rxclassDrugInfo.get("rxclassMinConceptItem");
								String classId = rxclassMinConceptItem.get("classId").toString();
								if( conceptTable.hasConcept(rxcui, sourceMap.get("RxNorm")) && conceptTable.hasConcept(classId, sourceMap.get("ATC")) ) {
									Concept c1 = conceptTable.getConcept(rxcui, sourceMap.get("RxNorm"));
									Concept c2 = conceptTable.getConcept(classId, sourceMap.get("ATC"));
									if( !concept2ConceptTable.containsPair(c1.getConceptId(), "memberof", c2.getConceptId()) ) {
										ConceptRelationship conRel = new ConceptRelationship();
										conRel.setId(++codeGenerator);
										conRel.setConceptId1(c1.getConceptId());
										conRel.setRelationship("memberof");
										conRel.setConceptId2(c1.getConceptId());
										
										concept2ConceptTable.add(conRel);
									}
								}
													
							}
						
						}
						
					}
				}
			}
		}
		
		addMisspellings();
		addTCodes();
		
	}
	
	private void setAuthoritativeSourceTable() {
		Source s1 = new Source();
		Source s2 = new Source();
		Source s3 = new Source();
		Source s4 = new Source();
		
		s1.setId(++codeGenerator);
		s1.setName("RxNorm");
		sourceMap.put("RxNorm", String.valueOf(codeGenerator) );
		
		s2.setId(++codeGenerator);
		s2.setName("ATC");
		sourceMap.put("ATC", String.valueOf(codeGenerator));
		
		s3.setId(++codeGenerator);
		s3.setName("ICD");
		sourceMap.put("ICD", String.valueOf(codeGenerator));

		s4.setId(++codeGenerator);
		s4.setName("Misspelling");
		sourceMap.put("Misspelling", String.valueOf(codeGenerator));
		
		
		authoritativeSourceTable.add(s1);
		authoritativeSourceTable.add(s2);
		authoritativeSourceTable.add(s3);
		authoritativeSourceTable.add(s4);
	}
	
	private void setConceptTypeTable() {
		ConceptType t1 = new ConceptType();
		ConceptType t2 = new ConceptType();
		
		t1.setId(++codeGenerator);
		t1.setDescription("Substance");
		classTypeMap.put("Substance", String.valueOf(codeGenerator));
		
		t2.setId(++codeGenerator);;
		t2.setDescription("Class");
		classTypeMap.put("Class", String.valueOf(codeGenerator));
		
		conceptTypeTable.add(t1);
		conceptTypeTable.add(t2);		
	}
	
	private void setTermTypeTable() {
		TermType t1 = new TermType();
		TermType t2 = new TermType();
		TermType t3 = new TermType();
		TermType t4 = new TermType();
		TermType t5 = new TermType();		
		
		t1.setId(++codeGenerator);
		t1.setAbbreviation("IN");
		termTypeMap.put("IN", String.valueOf(codeGenerator));
		
		t2.setId(++codeGenerator);
		t2.setAbbreviation("PIN");
		termTypeMap.put("PIN", String.valueOf(codeGenerator));
		
		t3.setId(++codeGenerator);
		t3.setAbbreviation("BN");
		termTypeMap.put("BN", String.valueOf(codeGenerator));
		
		t4.setId(++codeGenerator);
		t4.setAbbreviation("MSP");
		termTypeMap.put("MSP", String.valueOf(codeGenerator));		
		
		t5.setId(++codeGenerator);
		t5.setAbbreviation("SY");
		termTypeMap.put("SY", String.valueOf(codeGenerator));		
		
		termTypeTable.add(t1);
		termTypeTable.add(t2);
		termTypeTable.add(t3);
		termTypeTable.add(t4);		
		termTypeTable.add(t5);
		
	}
		
	private void serialize() {
		
		this.authoritativeSourceTable.print(this.authoritativeSourceFile);
		this.conceptTypeTable.print(this.conceptTypeFile);
		this.termTypeTable.print(this.termTypeFile);
		this.termTable.print(this.termFile);
		this.conceptTable.print(this.conceptFile);
		this.term2TermTable.print(this.term2termFile);
		this.concept2ConceptTable.print(this.concept2conceptFile);

	}
	
	private void cleanup() {
		authoritativeSourceFile.close();
		conceptTypeFile.close();
		termTypeFile.close();
		termFile.close();
		conceptFile.close();
		term2termFile.close();
		concept2conceptFile.close();
	}
	
	public static JSONObject getresult(String URLtoRead) throws IOException {
		URL url;
		HttpsURLConnection connexion;
		BufferedReader reader;
		
		String line;
		String result="";
		url= new URL(URLtoRead);
	
		connexion= (HttpsURLConnection) url.openConnection();
		connexion.setRequestMethod("GET");
		reader= new BufferedReader(new InputStreamReader(connexion.getInputStream()));	
		while ((line =reader.readLine())!=null) {
			result += line;
			
		}
		
		JSONObject json = new JSONObject(result);
		return json;
	}	

}
