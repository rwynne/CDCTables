package gov.nih.nlm.mor.db;

import java.io.BufferedReader;
import java.io.File;
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
	
	private HashMap<String, String> sourceMap = new HashMap<String, String>();
	private HashMap<String, String> termTypeMap = new HashMap<String, String>();
	private HashMap<String, String> classTypeMap = new HashMap<String, String>();
	private HashMap<String, ArrayList<String>> class2Parents = new HashMap<String, ArrayList<String>>();
	
	private Integer codeGenerator = 0;
//more?
	
	public static void main(String[] args) {
		CDCTables tables = new CDCTables();
		tables.configure();
		tables.gather();
		tables.serialize();
		tables.cleanup();
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
		String concept2conceptPath = "./concept-concept";
		
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
	
	private void gather() {
		JSONObject allConcepts = null;
		ArrayList<String> rxCuis = new ArrayList<String>();
		
		try {
			allConcepts = getresult(allConceptsUrl);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		setAuthoritativeSourceTable();
		setConceptTypeTable();
		setTermTypeTable();
		
		System.out.println(allConceptsUrl);
		if( allConcepts != null ) {
			JSONObject group = null;
			JSONArray minConceptArray = null;		
			
			group = (JSONObject) allConcepts.get("minConceptGroup");
			minConceptArray = (JSONArray) group.get("minConcept");
			for(int i = 0; i < minConceptArray.length(); i++ ) {
//				HashMap<Concept, ArrayList<Term>> concept2Terms = new HashMap<Concept, ArrayList<Term>>();
				Concept concept = new Concept();
				Term term = new Term();
				
				JSONObject minConcept = (JSONObject) minConceptArray.get(i);
				
				String rxcui = minConcept.get("rxcui").toString();
				String name = minConcept.get("name").toString();
				String type = minConcept.get("tty").toString();
				
				concept.setConceptId(++codeGenerator);
				concept.setSource("RxNorm");
				concept.setSourceId(rxcui);
				concept.setClassType(classTypeMap.get("Substance"));
				
				Integer conceptId = codeGenerator;
				
				term.setId(++codeGenerator);
				Integer preferredTermId = codeGenerator;
				
				concept.setPreferredTermId(preferredTermId);
				
				conceptTable.add(concept);
				
				term.setName(name);
				term.setTty(termTypeMap.get("IN")); //this could be IN instead
				term.setSourceId(rxcui);
				term.setSource("RxNorm");
				
				termTable.add(term);
				
			
				JSONObject allProperties = null;
				JSONObject allRelated = null;
				JSONObject allClasses = null;
				
				try {
					allRelated = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allrelated.json");
					allProperties = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allProperties.json?prop=all");
					allClasses = getresult("https://rxnav.nlm.nih.gov/REST/rxclass/class/byRxcui.json?rxcui=" + rxcui + "&relaSource=ATC"); //update for other sources?
				} catch(IOException e) {
					e.printStackTrace();
				}
				
				System.out.println("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allrelated.json");
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
								relatedTerm.setSource("RxNorm");
								
								termTable.add(relatedTerm);
								
								Integer termId = codeGenerator;
								
								TermRelationship termRel = new TermRelationship();
								termRel.setId(++codeGenerator);
								termRel.setTermId1(termId);
								termRel.setTermId2(preferredTermId);
								termRel.setRelationship(relatedType);
								
								term2TermTable.add(termRel);
								
						}
							
					}
						
				}
				
				//what are we looking for here?  Just UNII it seems
				//so far
				System.out.println("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allProperties.json?prop=all");
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
							synonym.setSource("RxNorm");
							
							termTable.add(synonym);
							
							Integer synonymId = codeGenerator;							
							
							TermRelationship termRel = new TermRelationship();
							termRel.setId(++codeGenerator);
							termRel.setTermId1(synonymId);							
							termRel.setTermId2(preferredTermId);
							termRel.setRelationship("SY");
							
							term2TermTable.add(termRel);
							
						}
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
				
				System.out.println("https://rxnav.nlm.nih.gov/REST/rxclass/class/byRxcui.json?rxcui=" + rxcui + "&relaSource=ATC");
				if( allClasses != null ) {
					if( !allClasses.isNull("rxclassDrugInfoList") ) {
						JSONObject rxclassdrugInfoList = (JSONObject) allClasses.get("rxclassDrugInfoList");
						JSONArray drugInfoList = (JSONArray) rxclassdrugInfoList.get("rxclassDrugInfo");
						
						for( int j=0; j < drugInfoList.length(); j++ ) {
							JSONObject rxclassDrugInfo = (JSONObject) drugInfoList.get(j);
							if( !rxclassDrugInfo.isNull("rxclassMinConceptItem") ) {
								JSONObject rxclassMinConceptItem = (JSONObject) rxclassDrugInfo.get("rxclassMinConceptItem");
								Concept sourceConcept = new Concept();
								Term sourceTerm = new Term();
								
								sourceTerm.setId(++codeGenerator);
								Integer sourceTermId = codeGenerator;
								sourceTerm.setName(rxclassMinConceptItem.get("className").toString());
								sourceTerm.setSourceId(rxclassMinConceptItem.get("classId").toString());
								sourceTerm.setTty("");
								sourceTerm.setSource(sourceMap.get("ATC"));
								
								termTable.add(sourceTerm);
								
								sourceConcept.setConceptId(++codeGenerator);
								sourceConcept.setPreferredTermId(sourceTermId);
								sourceConcept.setSource(sourceMap.get("ATC"));
								sourceConcept.setSourceId(rxclassMinConceptItem.get("classId").toString());
								sourceConcept.setClassType(classTypeMap.get("Class"));
								
								Integer sourceConceptId = codeGenerator;
								
								conceptTable.add(sourceConcept);
								
								ConceptRelationship conRel = new ConceptRelationship();
								conRel.setId(++codeGenerator);
								conRel.setConceptId1(conceptId);
								conRel.setConceptId2(sourceConceptId);
								conRel.setRelationship("memberof");
								
								concept2ConceptTable.add(conRel);
								
								JSONObject classGraph = null;
								
								try {
									classGraph = getresult("https://rxnav.nlm.nih.gov/REST/rxclass/classGraph.json?classId=" +sourceConceptId + "&source=ATC1-4");
								} catch (IOException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
								
								System.out.println("https://rxnav.nlm.nih.gov/REST/rxclass/classGraph.json?classId=" +sourceConceptId + "&source=ATC1-4");
								if( classGraph != null && !classGraph.isNull("rxclassGraph") ) {
									JSONObject rxClassGraph = (JSONObject) classGraph.get("rxclassGraph");
									if( !rxClassGraph.isNull("rxclassMinConceptItem") && !rxClassGraph.isNull("rxclassEdge") ) {
										JSONArray classConcepts = (JSONArray) rxClassGraph.get("rxclassMinConceptItem");
										JSONArray classEdges = (JSONArray) rxClassGraph.get("rxclassEdge");
										HashMap<String, String> edgeMap = new HashMap<String, String>();
										HashMap<String, String> conceptMap = new HashMap<String, String>();
										
										for( int k=0; k < classConcepts.length(); k++ ) {
											JSONObject classConcept = (JSONObject) classConcepts.get(k);
											conceptMap.put(classConcept.get("classId").toString(), classConcept.get("className").toString());
										}
										
										for( int k=0; k < classEdges.length(); k++ ) {
											JSONObject classEdge = (JSONObject) classEdges.get(k);
											edgeMap.put(classEdge.get("classId1").toString(), classEdge.get("classId2").toString());
										}	
										
										for( String s : conceptMap.keySet() ) {
											if( !conceptTable.hasConcept(s, sourceMap.get("ATC")) ) {
												Concept classConcept = new Concept();
												classConcept.setConceptId(++codeGenerator);
												Integer classConceptCode = codeGenerator;
												classConcept.setSource(sourceMap.get("ATC"));
												classConcept.setClassType(classTypeMap.get("Class"));
												classConcept.setSourceId(s);
												
												Term classTerm = new Term();
												classTerm.setId(++codeGenerator);
												Integer classTermCode = codeGenerator;
												classTerm.setName(conceptMap.get(s));
												classTerm.setSource(sourceMap.get("ATC"));
												classTerm.setSourceId(s);
												classTerm.setTty("");
												
												classConcept.setPreferredTermId(classTermCode);
												
												conceptTable.add(classConcept);
												termTable.add(classTerm);
												
												if( edgeMap.containsKey(s) ) {
													if( !classRelExists(s, edgeMap.get(s)) ) {
														addClassRelToMap(s, edgeMap.get(s));
														
														String parentSourceId = s;
														String parentName = conceptMap.get(s);
														
														Concept parentConcept = new Concept();
														parentConcept.setConceptId(++codeGenerator);
														Integer parentConceptId = codeGenerator;
														parentConcept.setSource(sourceMap.get("ATC"));
														parentConcept.setSourceId(parentSourceId);
														parentConcept.setClassType(classTypeMap.get("Class"));
														
														Term parentTerm = new Term();
														parentTerm.setId(++codeGenerator);
														Integer parentTermCode = codeGenerator;
														parentTerm.setName(parentName);
														parentTerm.setSource(sourceMap.get("ATC"));
														parentTerm.setSourceId(parentSourceId);
														
														parentConcept.setPreferredTermId(parentTermCode);
														
														ConceptRelationship parentConceptRel = new ConceptRelationship();
														parentConceptRel.setId(++codeGenerator);
														parentConceptRel.setConceptId1(classConceptCode);
														parentConceptRel.setRelationship("isa");
														parentConceptRel.setConceptId2(parentConceptId);
														
														conceptTable.add(parentConcept);
														termTable.add(parentTerm);
														concept2ConceptTable.add(parentConceptRel);
													
													}
													
												}
												
											}
										}
										
									}
									
								}
								
								
							}
							
						}
						
					}
					
				}
			}
		}
	}
	
	private void setAuthoritativeSourceTable() {
		Source s1 = new Source();
		Source s2 = new Source();
		Source s3 = new Source();
		
		s1.setId(++codeGenerator);
		s1.setName("RxNorm");
		sourceMap.put("RxNorm", String.valueOf(codeGenerator) );
		
		s2.setId(++codeGenerator);
		s2.setName("ATC");
		sourceMap.put("ATC", String.valueOf(codeGenerator));
		
		s3.setId(++codeGenerator);
		s3.setName("ICD");
		sourceMap.put("ICD", String.valueOf(codeGenerator));
		
		authoritativeSourceTable.add(s1);
		authoritativeSourceTable.add(s2);
		authoritativeSourceTable.add(s3);
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
		
		t1.setId(++codeGenerator);
		t1.setAbbreviation("IN");
		termTypeMap.put("IN", String.valueOf(codeGenerator));
		
		t2.setId(++codeGenerator);
		t2.setAbbreviation("PIN");
		termTypeMap.put("IN", String.valueOf(codeGenerator));
		
		t3.setId(++codeGenerator);
		t3.setAbbreviation("BN");
		termTypeMap.put("BN", String.valueOf(codeGenerator));
		
		termTypeTable.add(t1);
		termTypeTable.add(t2);
		termTypeTable.add(t3);
		
	}
		
	private boolean classRelExists(String cls, String classParent ) {
		boolean exists = false;
		if( class2Parents.containsKey(cls) ) {
			ArrayList<String> parents = class2Parents.get(cls);
			for(String p : parents ) {
				if( p.equals(classParent) ) {
					exists = true;
					break;
				}
			}
		}
		return exists;
	}
	
	private void addClassRelToMap(String cls, String classParent ) {
		if( !class2Parents.containsKey(cls) ) {
			ArrayList<String> parentClasses = new ArrayList<String>();
			parentClasses.add(classParent);
			class2Parents.put(cls, parentClasses);
		}
		else {
			ArrayList<String> parentClasses = class2Parents.get(cls);
			parentClasses.add(classParent);
			class2Parents.put(cls, parentClasses);
		}
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
