/*
 * NCHS terminology database
 * Sample queries, v2
 * 03OCT2019
 * Olivier Bodenreider / Robert Wynne
 */


show tables;
;

 Tables_in_opioid
 --------------------------
 NLMDrugAuthoritativeSource
 NLMDrugConcept
 NLMDrugConceptType
 NLMDrugConcepttoConcept
 NLMDrugTerm
 NLMDrugTermTerm
 NLMDrugTermType
;

describe NLMDrugConcept;
;

 Field                     Type             Null Key Default Extra
 ------------------------- ---------------- ---- --- ------- -----
 DrugConceptID             int(10) unsigned NO   PRI NULL    
 PreferredTermID           bigint(20)       NO       NULL    
 DrugAuthoritativeSourceID smallint(6)      YES      NULL    
 DrugConceptTypeID         bigint(20)       YES      NULL    
 DrugSourceConceptID       varchar(32)      YES      NULL    
 CreationDate              datetime         YES      NULL    
 CreationUserID            char(4)          YES      NULL    
 UpdatedDate               datetime         YES      NULL    
 UpdateUserID              char(4)          YES      NULL    
 IsActive                  tinyint(1)       YES      NULL    
;


describe NLMDrugTerm;
;

 Field                     Type             Null Key Default Extra
 ------------------------- ---------------- ---- --- ------- -----
 DrugTermID                int(10) unsigned NO   PRI NULL    
 DrugTermName              varchar(500)     NO   MUL NULL    
 DrugTTYID                 smallint(6)      YES      NULL    
 DrugExternalID            varchar(32)      YES      NULL    
 DrugAuthoritativeSourceID smallint(6)      YES      NULL    
 CreationUserID            char(4)          YES      NULL    
 CreationDate              datetime         YES      NULL    
 UpdatedUserID             char(5)          YES      NULL    
 UpdatedDate               datetime         YES      NULL    
 IsActive                  tinyint(1)       YES      NULL    
 DrugConceptID             bigint(20)       YES      NULL    
;


describe NLMDrugTermTerm;
;

 Field            Type             Null Key Default Extra
 ---------------- ---------------- ---- --- ------- -----
 DrugTermTermID   int(10) unsigned NO   PRI NULL    
 DrugTermID1      bigint(20)       YES      NULL    
 Relation         char(50)         YES      NULL    
 DrugTermID2      bigint(20)       YES      NULL    
 CreationUserID   char(4)          YES      NULL    
 CreationDateTime datetime         YES      NULL    
 UpdatedUserID    char(4)          YES      NULL    
 UpdatedDateTime  datetime         YES      NULL    
 IsActive         tinyint(1)       YES      NULL    
;


describe NLMDrugConcepttoConcept;
;
 Field                Type             Null Key Default Extra
 -------------------- ---------------- ---- --- ------- -----
 DrugConceptConceptID int(10) unsigned NO   PRI NULL    
 DrugConceptID1       bigint(20)       NO       NULL    
 Relation             char(50)         YES      NULL    
 DrugConceptID2       bigint(20)       NO       NULL    
 CreationUserID       char(4)          YES      NULL    
 CreationDateTime     datetime         YES      NULL    
 UpdatedUserID        char(4)          YES      NULL    
 UpdatedDateTime      datetime         YES      NULL    
 IsActive             tinyint(1)       YES      NULL    
;


describe NLMDrugTermType;

 Field          Type             Null Key Default Extra
 -------------- ---------------- ---- --- ------- -----
 DrugTTYID      int(10) unsigned NO   PRI NULL    
 Abbreviation   char(4)          YES  MUL NULL    
 Description    char(50)         YES  MUL NULL    
 CreationUserID char(4)          YES      NULL    
 CreationDate   datetime         YES      NULL    
 UpdatedUserID  char(5)          YES      NULL    
 UpdatedDate    datetime         YES      NULL    
 IsActive       tinyint(1)       YES      NULL    
;


describe NLMDrugAuthoritativeSource;

 Field                     Type             Null Key Default Extra
 ------------------------- ---------------- ---- --- ------- -----
 DrugAuthoritativeSourceID int(10) unsigned NO   PRI NULL    
 Name                      varchar(50)      NO   MUL NULL    
 Description               varchar(100)     YES  MUL NULL    
 CreationUserID            char(4)          YES      NULL    
 CreationDate              datetime         YES      NULL    
 UpdatedUserID             char(5)          YES      NULL    
 UpdatedDate               datetime         YES      NULL    
 IsActive                  tinyint(1)       YES      NULL    
;


# ============================================================
#	find concept by name
# ============================================================
;

/*
 * find concept by name (preferred)
 */
select
	C.DrugConceptID,
	T.DrugTermID, 
	T.DrugTermName,
	C.DrugSourceConceptID
from NLMDrugConcept C, NLMDrugTerm T
where C.PreferredTermID = T.DrugTermID
and T.DrugTermName = 'ethanol'
;
 DrugConceptID DrugTermID DrugTermName DrugSourceConceptID
 ------------- ---------- ------------ -------------------
         32458      32457 Ethanol      448
;

/*
 * find concept by name (BN, synonym)
 */
select
	C.DrugConceptID,
	T1.DrugTermID, 
	T1.DrugTermName,
	C.DrugSourceConceptID,
	RT.Relation
from NLMDrugConcept C, NLMDrugTerm T1, NLMDrugTerm T2, NLMDrugTermTerm RT
where C.PreferredTermID = T1.DrugTermID
and RT.DrugTermID1 = T2.DrugTermID
and RT.DrugTermID2 = T1.DrugTermID
and T2.DrugTermName = 'ethanol'
;
 DrugConceptID DrugTermID DrugTermName                  DrugSourceConceptID Relation
 ------------- ---------- ----------------------------- ------------------- --------
         62206      62205 3,4-Methylenedioxyamphetamine 7400                SY
;

/*
 * find concept by name (preferred)
 */
select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T.DrugTermID, 
	T.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where T.DrugTermName = 'atorvastatin'
and C.PreferredTermID = T.DrugTermID
and T.DrugTTYID = TT.DrugTTYID
and T.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName Abbreviation Name   DrugExternalID
 ------------- ------------------- ---------- ------------ ------------ ------ --------------
         13066 83367                    13065 atorvastatin IN           RxNorm 83367
;

/*
 * find concept by name (preferred)
 */
select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T.DrugTermID, 
	T.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where T.DrugTermName = 'Acetaminophen'
and C.PreferredTermID = T.DrugTermID
and T.DrugTTYID = TT.DrugTTYID
and T.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName  Abbreviation Name   DrugExternalID
 ------------- ------------------- ---------- ------------- ------------ ------ --------------
          7701 161                       7700 Acetaminophen IN           RxNorm 161
;

/*
 * find concept by name (any term type)
 */
select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T1.DrugTermID, 
	T1.DrugTermName,
	T2.DrugTermID, 
	T2.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T2.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T1, 
	NLMDrugTerm T2, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where T2.DrugTermName IN ('flurazepaym', 'cyprodente', 'sufentdanil', 'yerivedge')
and C.PreferredTermID = T1.DrugTermID
and C.DrugConceptID = T2.DrugConceptID
and T2.DrugTTYID = TT.DrugTTYID
and T2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID order by T2.DrugTermName
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName DrugTermID DrugTermName Abbreviation Name        DrugExternalID
 ------------- ------------------- ---------- ------------ ---------- ------------ ------------ ----------- --------------
         26459 22051                    26458 cyprodenate     1011946 cyprodente   MSP          Misspelling 
         34869 4501                     34868 Flurazepam      1129402 flurazepaym  MSP          Misspelling 
         72576 56795                    72575 Sufentanil      1853170 sufentdanil  MSP          Misspelling 
         79454 1242987                  79453 vismodegib      1854652 yerivedge    MSP          Misspelling 
;

select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T1.DrugTermID, 
	T1.DrugTermName,
	T2.DrugTermID, 
	T2.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T2.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T1, 
	NLMDrugTerm T2, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where T2.DrugTermName IN ('oxycodone', 'hydrocodone')
and C.PreferredTermID = T1.DrugTermID
and C.DrugConceptID = T2.DrugConceptID
and T2.DrugTTYID = TT.DrugTTYID
and T2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName DrugTermID DrugTermName Abbreviation Name   DrugExternalID
 ------------- ------------------- ---------- ------------ ---------- ------------ ------------ ------ --------------
         39837 5489                     39836 Hydrocodone       39836 Hydrocodone  IN           RxNorm 5489
         39837 5489                     39836 Hydrocodone       39946 Hydrocodone  UNII         FDA    6YKS4Y3WQ7
         39837 5489                     39836 Hydrocodone     2075094 Hydrocodone  PV           NFLIS  
         39837 5489                     39836 Hydrocodone     2075096 HYDROCODONE  SY           NFLIS  
         39837 5489                     39836 Hydrocodone     2081092 Hydrocodone  PV           DEA    9193
         56429 7804                     56428 Oxycodone         56428 Oxycodone    IN           RxNorm 7804
         56429 7804                     56428 Oxycodone         56466 Oxycodone    UNII         FDA    CD35PMG570
         56429 7804                     56428 Oxycodone       2075069 Oxycodone    PV           NFLIS  
         56429 7804                     56428 Oxycodone       2075071 OXYCODONE    SY           NFLIS  
         56429 7804                     56428 Oxycodone       2081249 Oxycodone    PV           DEA    9143

;

# ============================================================
#	get class for concept
# ============================================================
;

/*
 * get class for concept
 */
select
	distinct	
	C1.DrugConceptID,
	C2.DrugConceptID,
	RC.Relation,
	T.DrugTermID, 
	T.DrugTermName,
	C2.DrugSourceConceptID,
	TS.Name
from 
	NLMDrugConcept C1, 
	NLMDrugConcept C2, 
	NLMDrugTerm T, 
	NLMDrugConcepttoConcept RC,
	NLMDrugAuthoritativeSource TS
where C2.PreferredTermID = T.DrugTermID
and RC.DrugConceptID1 = C1.DrugConceptID
and RC.DrugConceptID2 = C2.DrugConceptID
and C2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
and C1.DrugConceptID = '32458'
;
DrugConceptID DrugConceptID Relation DrugTermID DrugTermName                                                                                                        DrugSourceConceptID Name
 ------------- ------------- -------- ---------- ------------------------------------------------------------------------------------------------------------------- ------------------- -----
         32458          3331 memberof       3330 Other antiseptics and disinfectants                                                                                 D08AX               ATC
         32458          4649 memberof       4648 Antidotes                                                                                                           V03AB               ATC
         32458          4669 memberof       4668 Nerve depressants                                                                                                   V03AZ               ATC
         32458          1400 memberof       1399 Poisoning by local astringents and local detergents                                                                 T49.2               ICD
         32458          1648 memberof       1647 Toxic effect of alcohol, unspecified                                                                                T51.9               ICD
         32458          1654 memberof       1653 Toxic effect of ethanol                                                                                             T51.0               ICD
         32458       2064972 memberof    2064971 Other substances -- steroids, phencyclidine, precursors, reagents  (DEA categories 410 - 420, 550 - 555, 800 - 820)                     NFLIS
;


/*
 * get class for concept
 */
select
	distinct	
	C1.DrugConceptID,
	C2.DrugConceptID,
	RC.Relation,
	T.DrugTermID, 
	T.DrugTermName,
	C2.DrugSourceConceptID,
	TS.Name
from 
	NLMDrugConcept C1, 
	NLMDrugConcept C2, 
	NLMDrugTerm T, 
	NLMDrugConcepttoConcept RC,
	NLMDrugAuthoritativeSource TS
where C2.PreferredTermID = T.DrugTermID
and RC.DrugConceptID1 = C1.DrugConceptID
and RC.DrugConceptID2 = C2.DrugConceptID
and C2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
and C1.DrugConceptID = '72576'
;
 DrugConceptID DrugConceptID Relation DrugTermID DrugTermName                           DrugSourceConceptID Name
 ------------- ------------- -------- ---------- -------------------------------------- ------------------- -----
         72576          4079 memberof       4078 Opioid anesthetics                     N01AH               ATC
         72576           246 memberof        245 Poisoning by other synthetic narcotics T40.4               ICD
         72576       2074973 memberof    2074972 Narcotic Analgesics                                        NFLIS
         72576       2078818 memberof    2078817 Narcotic                               NARC1               DEA
         72576       2080962 memberof    2080961 SCHEDULE II                                                DEA
;


# ============================================================
#	get class hierarchy
# ============================================================
;

/*
 * get class hierarchy (direct parents)
 */
select
	distinct	
	C1.DrugConceptID,
	C2.DrugConceptID,
	RC.Relation,
	T.DrugTermID, 
	T.DrugTermName,
	C2.DrugSourceConceptID
from NLMDrugConcept C1, NLMDrugConcept C2, NLMDrugTerm T, NLMDrugConcepttoConcept RC
where C2.PreferredTermID = T.DrugTermID
and RC.DrugConceptID1 = C1.DrugConceptID
and RC.DrugConceptID2 = C2.DrugConceptID
and C1.DrugConceptID = '2266' -- Poisoning by hormones and their synthetic substitutes and antagonists, not elsewhere classified
;
DrugConceptID DrugConceptID Relation DrugTermID DrugTermName                                                                                    DrugSourceConceptID
 ------------- ------------- -------- ---------- ----------------------------------------------------------------------------------------------- -------------------
          2266          2046 isa            2045 Poisoning by hormones and their synthetic substitutes and antagonists, not elsewhere classified T38

;

select
	distinct	
	C1.DrugConceptID,
	C2.DrugConceptID,
	RC.Relation,
	T.DrugTermID, 
	T.DrugTermName,
	C2.DrugSourceConceptID
from NLMDrugConcept C1, NLMDrugConcept C2, NLMDrugTerm T, NLMDrugConcepttoConcept RC
where C2.PreferredTermID = T.DrugTermID
and RC.DrugConceptID1 = C1.DrugConceptID
and RC.DrugConceptID2 = C2.DrugConceptID
and C1.DrugConceptID = '40454' 
;
 DrugConceptID DrugConceptID Relation DrugTermID DrugTermName               DrugSourceConceptID
 ------------- ------------- -------- ---------- -------------------------- -------------------
         40454          4097 memberof       4096 Natural opium alkaloids    N02AA
         40454           228 memberof        227 Poisoning by other opioids T40.2
         40454       2074973 memberof    2074972 Narcotic Analgesics        
         40454       2078818 memberof    2078817 Narcotic                   NARC1
         40454       2080962 memberof    2080961 SCHEDULE II                
;






# ============================================================
#	get term relations (e.g., misspellings)
# ============================================================
;

 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName Abbreviation Name   DrugExternalID
 ------------- ------------------- ---------- ------------ ------------ ------ --------------
         41894 11289                    41893 Warfarin     IN           RxNorm 11289
;

/*
 * get term relations (e.g., misspellings)
 * *** only the direct misspellings of the term will be returned
 * *** e.g., 
 * *** lipitar will be returned for 7434 Lipitor
 * *** lipitar will NOT be returned for 7432 atorvastatin
 */
select
	distinct
	T1.DrugTermID, 
	T1.DrugTermName,
	T2.DrugTermID, 
	T2.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T2.DrugExternalID,
	RT.Relation
from 
	NLMDrugTerm T1, 
	NLMDrugTerm T2, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS,
	NLMDrugTermTerm RT
where T1.DrugTermID = '76467'
and RT.DrugTermID2 = T1.DrugTermID
and RT.DrugTermID1 = T2.DrugTermID
and T2.DrugTTYID = TT.DrugTTYID
and T2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
;
 DrugTermID DrugTermName DrugTermID DrugTermName            Abbreviation Name        DrugExternalID Relation
 ---------- ------------ ---------- ----------------------- ------------ ----------- -------------- --------
      76467 Trazodone                    76469 Oleptro                 BN           RxNorm      898698         BN
      76467 Trazodone                    76471 Trazodone Hydrochloride PIN          RxNorm      82112          PIN
      76467 Trazodone                    76473 Trazodone               UNII         FDA         YBK48BXK30     UNII
      76467 Trazodone                   404960 trazodwone              MSP          Misspelling                MSP
      76467 Trazodone                   404962 trajzodone              MSP          Misspelling                MSP
      76467 Trazodone                   404964 trazodony               MSP          Misspelling                MSP
      76467 Trazodone                   404966 trazodowne              MSP          Misspelling                MSP
      76467 Trazodone                   404968 ttrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   404970 trazodtone              MSP          Misspelling                MSP
      76467 Trazodone                   404972 truazodone              MSP          Misspelling                MSP
      76467 Trazodone                   404974 traziodone              MSP          Misspelling                MSP
      76467 Trazodone                   404976 trauzodone              MSP          Misspelling                MSP
      76467 Trazodone                   404978 trozodone               MSP          Misspelling                MSP
      76467 Trazodone                   404980 trazodonue              MSP          Misspelling                MSP
      76467 Trazodone                   404982 traozodone              MSP          Misspelling                MSP
      76467 Trazodone                   404984 tdrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   404986 trazodonye              MSP          Misspelling                MSP
      76467 Trazodone                   404988 trazidone               MSP          Misspelling                MSP
      76467 Trazodone                   404990 trazydone               MSP          Misspelling                MSP
      76467 Trazodone                   404992 trahzodone              MSP          Misspelling                MSP
      76467 Trazodone                   404994 tryzodone               MSP          Misspelling                MSP
      76467 Trazodone                   404996 twrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   404998 traazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405000 trazodyne               MSP          Misspelling                MSP
      76467 Trazodone                   405002 trazodonwe              MSP          Misspelling                MSP
      76467 Trazodone                   405004 trazodoone              MSP          Misspelling                MSP
      76467 Trazodone                   405006 trazodoane              MSP          Misspelling                MSP
      76467 Trazodone                   405008 trazodoine              MSP          Misspelling                MSP
      76467 Trazodone                   405010 trazaodone              MSP          Misspelling                MSP
      76467 Trazodone                   405012 tryazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405014 trazodhne               MSP          Misspelling                MSP
      76467 Trazodone                   405016 trazzodone              MSP          Misspelling                MSP
      76467 Trazodone                   405018 trazodona               MSP          Misspelling                MSP
      76467 Trazodone                   405020 trazodane               MSP          Misspelling                MSP
      76467 Trazodone                   405022 trazodwne               MSP          Misspelling                MSP
      76467 Trazodone                   405024 trazodtne               MSP          Misspelling                MSP
      76467 Trazodone                   405026 trwazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405028 trazwodone              MSP          Misspelling                MSP
      76467 Trazodone                   405030 trazodonie              MSP          Misspelling                MSP
      76467 Trazodone                   405032 troazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405034 trazodjne               MSP          Misspelling                MSP
      76467 Trazodone                   405036 triazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405038 trazodoneh              MSP          Misspelling                MSP
      76467 Trazodone                   405040 trazoddne               MSP          Misspelling                MSP
      76467 Trazodone                   405042 trayzodone              MSP          Misspelling                MSP
      76467 Trazodone                   405044 trazodoni               MSP          Misspelling                MSP
      76467 Trazodone                   405046 trzodone                MSP          Misspelling                MSP
      76467 Trazodone                   405048 trazodonne              MSP          Misspelling                MSP
      76467 Trazodone                   405050 trhzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405052 trazodonh               MSP          Misspelling                MSP
      76467 Trazodone                   405054 trazodojne              MSP          Misspelling                MSP
      76467 Trazodone                   405056 trazodoney              MSP          Misspelling                MSP
      76467 Trazodone                   405058 trazodhone              MSP          Misspelling                MSP
      76467 Trazodone                   405060 trazadone               MSP          Misspelling                MSP
      76467 Trazodone                   405062 thrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405064 trszodone               MSP          Misspelling                MSP
      76467 Trazodone                   405066 trazodogne              MSP          Misspelling                MSP
      76467 Trazodone                   405068 trazodonhe              MSP          Misspelling                MSP
      76467 Trazodone                   405070 trazodonae              MSP          Misspelling                MSP
      76467 Trazodone                   405072 trazodine               MSP          Misspelling                MSP
      76467 Trazodone                   405074 trazoduone              MSP          Misspelling                MSP
      76467 Trazodone                   405076 trezodone               MSP          Misspelling                MSP
      76467 Trazodone                   405078 trazwdone               MSP          Misspelling                MSP
      76467 Trazodone                   405080 treazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405082 tyrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405084 traezodone              MSP          Misspelling                MSP
      76467 Trazodone                   405086 trazodonu               MSP          Misspelling                MSP
      76467 Trazodone                   405088 trazeodone              MSP          Misspelling                MSP
      76467 Trazodone                   405090 trrzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405092 trazoadone              MSP          Misspelling                MSP
      76467 Trazodone                   405094 trazodonee              MSP          Misspelling                MSP
      76467 Trazodone                   405096 traztdone               MSP          Misspelling                MSP
      76467 Trazodone                   405098 trazoodone              MSP          Misspelling                MSP
      76467 Trazodone                   405100 trazodene               MSP          Misspelling                MSP
      76467 Trazodone                   405102 trazodoene              MSP          Misspelling                MSP
      76467 Trazodone                   405104 trwzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405106 dtrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405108 tirazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405110 htrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405112 trazodono               MSP          Misspelling                MSP
      76467 Trazodone                   405114 trazodonn               MSP          Misspelling                MSP
      76467 Trazodone                   405116 trhazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405118 trazoidone              MSP          Misspelling                MSP
      76467 Trazodone                   405120 trawzodone              MSP          Misspelling                MSP
      76467 Trazodone                   405122 trazotdone              MSP          Misspelling                MSP
      76467 Trazodone                   405124 turazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405126 trazodune               MSP          Misspelling                MSP
      76467 Trazodone                   405128 wtrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405130 trazodaone              MSP          Misspelling                MSP
      76467 Trazodone                   405132 tarazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405134 trazodonea              MSP          Misspelling                MSP
      76467 Trazodone                   405136 trazzdone               MSP          Misspelling                MSP
      76467 Trazodone                   405138 trazddone               MSP          Misspelling                MSP
      76467 Trazodone                   405140 trzzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405142 trazodohne              MSP          Misspelling                MSP
      76467 Trazodone                   405144 trjzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405146 trczodone               MSP          Misspelling                MSP
      76467 Trazodone                   405148 trazuodone              MSP          Misspelling                MSP
      76467 Trazodone                   405150 trazodione              MSP          Misspelling                MSP
      76467 Trazodone                   405152 trazodyone              MSP          Misspelling                MSP
      76467 Trazodone                   405154 trazoedone              MSP          Misspelling                MSP
      76467 Trazodone                   405156 trazodoune              MSP          Misspelling                MSP
      76467 Trazodone                   405158 trazoddone              MSP          Misspelling                MSP
      76467 Trazodone                   405160 trazoudone              MSP          Misspelling                MSP
      76467 Trazodone                   405162 trazudone               MSP          Misspelling                MSP
      76467 Trazodone                   405164 drazodone               MSP          Misspelling                MSP
      76467 Trazodone                   405166 truzodone               MSP          Misspelling                MSP
      76467 Trazodone                   405168 trazedone               MSP          Misspelling                MSP
      76467 Trazodone                   405170 trazodeone              MSP          Misspelling                MSP
      76467 Trazodone                   405172 traczodone              MSP          Misspelling                MSP
      76467 Trazodone                   405174 trazodoneo              MSP          Misspelling                MSP
      76467 Trazodone                   405176 trazohdone              MSP          Misspelling                MSP
      76467 Trazodone                   405178 trazodoneu              MSP          Misspelling                MSP
      76467 Trazodone                   405180 torazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405182 trazodonew              MSP          Misspelling                MSP
      76467 Trazodone                   405184 traizodone              MSP          Misspelling                MSP
      76467 Trazodone                   405186 trazodon                MSP          Misspelling                MSP
      76467 Trazodone                   405188 terazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405190 trazotone               MSP          Misspelling                MSP
      76467 Trazodone                   405192 trizodone               MSP          Misspelling                MSP
      76467 Trazodone                   405194 trazodonoe              MSP          Misspelling                MSP
      76467 Trazodone                   405196 trazodoyne              MSP          Misspelling                MSP
      76467 Trazodone                   405198 trazodne                MSP          Misspelling                MSP
      76467 Trazodone                   405200 trazodonw               MSP          Misspelling                MSP
      76467 Trazodone                   405202 trazowdone              MSP          Misspelling                MSP
      76467 Trazodone                   405204 trazoydone              MSP          Misspelling                MSP
      76467 Trazodone                   405206 trazodnne               MSP          Misspelling                MSP
      76467 Trazodone                   405208 trazodonei              MSP          Misspelling                MSP
      76467 Trazodone                   405210 trrazodone              MSP          Misspelling                MSP
      76467 Trazodone                   405212 traszodone              MSP          Misspelling                MSP
      76467 Trazodone                   405214 trazyodone              MSP          Misspelling                MSP
      76467 Trazodone                   405216 trasodone               MSP          Misspelling                MSP
      76467 Trazodone                   405218 trazdone                MSP          Misspelling                MSP
      76467 Trazodone                   405220 oleoptro                MSP          Misspelling                MSP
      76467 Trazodone                   405222 oleptrou                MSP          Misspelling                MSP
      76467 Trazodone                   405224 olyptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405226 olepatro                MSP          Misspelling                MSP
      76467 Trazodone                   405228 olwptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405230 olepttro                MSP          Misspelling                MSP
      76467 Trazodone                   405232 olptro                  MSP          Misspelling                MSP
      76467 Trazodone                   405234 oyleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405236 olepthro                MSP          Misspelling                MSP
      76467 Trazodone                   405238 oileptro                MSP          Misspelling                MSP
      76467 Trazodone                   405240 oljeptro                MSP          Misspelling                MSP
      76467 Trazodone                   405242 oleptrr                 MSP          Misspelling                MSP
      76467 Trazodone                   405244 olepptro                MSP          Misspelling                MSP
      76467 Trazodone                   405246 oloeptro                MSP          Misspelling                MSP
      76467 Trazodone                   405248 oleptruo                MSP          Misspelling                MSP
      76467 Trazodone                   405250 oleptwro                MSP          Misspelling                MSP
      76467 Trazodone                   405252 olleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405254 oloptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405256 jleptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405258 yleptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405260 oleptrwo                MSP          Misspelling                MSP
      76467 Trazodone                   405262 oleptru                 MSP          Misspelling                MSP
      76467 Trazodone                   405264 olebtro                 MSP          Misspelling                MSP
      76467 Trazodone                   405266 oleaptro                MSP          Misspelling                MSP
      76467 Trazodone                   405268 oleptryo                MSP          Misspelling                MSP
      76467 Trazodone                   405270 uleptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405272 olepetro                MSP          Misspelling                MSP
      76467 Trazodone                   405274 olepitro                MSP          Misspelling                MSP
      76467 Trazodone                   405276 eoleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405278 oleptroa                MSP          Misspelling                MSP
      76467 Trazodone                   405280 oeleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405282 olepdro                 MSP          Misspelling                MSP
      76467 Trazodone                   405284 oleptreo                MSP          Misspelling                MSP
      76467 Trazodone                   405286 olhptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405288 woleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405290 aoleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405292 oleptaro                MSP          Misspelling                MSP
      76467 Trazodone                   405294 oleptrro                MSP          Misspelling                MSP
      76467 Trazodone                   405296 oleptrh                 MSP          Misspelling                MSP
      76467 Trazodone                   405298 olepturo                MSP          Misspelling                MSP
      76467 Trazodone                   405300 olpptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405302 oleptrow                MSP          Misspelling                MSP
      76467 Trazodone                   405304 oleptre                 MSP          Misspelling                MSP
      76467 Trazodone                   405306 oleptry                 MSP          Misspelling                MSP
      76467 Trazodone                   405308 oleptrio                MSP          Misspelling                MSP
      76467 Trazodone                   405310 oleptri                 MSP          Misspelling                MSP
      76467 Trazodone                   405312 eleptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405314 oliptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405316 oleputro                MSP          Misspelling                MSP
      76467 Trazodone                   405318 joleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405320 oleptra                 MSP          Misspelling                MSP
      76467 Trazodone                   405322 ouleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405324 olepdtro                MSP          Misspelling                MSP
      76467 Trazodone                   405326 ohleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405328 oleptroy                MSP          Misspelling                MSP
      76467 Trazodone                   405330 olueptro                MSP          Misspelling                MSP
      76467 Trazodone                   405332 oleptr                  MSP          Misspelling                MSP
      76467 Trazodone                   405334 oaleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405336 oleptrao                MSP          Misspelling                MSP
      76467 Trazodone                   405338 oleptoro                MSP          Misspelling                MSP
      76467 Trazodone                   405340 olheptro                MSP          Misspelling                MSP
      76467 Trazodone                   405342 aleptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405344 oleptyro                MSP          Misspelling                MSP
      76467 Trazodone                   405346 ileptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405348 olepjtro                MSP          Misspelling                MSP
      76467 Trazodone                   405350 ollptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405352 ojleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405354 oleptroe                MSP          Misspelling                MSP
      76467 Trazodone                   405356 uoleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405358 oleyptro                MSP          Misspelling                MSP
      76467 Trazodone                   405360 yoleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405362 ioleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405364 oleptdro                MSP          Misspelling                MSP
      76467 Trazodone                   405366 oleptroi                MSP          Misspelling                MSP
      76467 Trazodone                   405368 olweptro                MSP          Misspelling                MSP
      76467 Trazodone                   405370 olieptro                MSP          Misspelling                MSP
      76467 Trazodone                   405372 owleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405374 olepotro                MSP          Misspelling                MSP
      76467 Trazodone                   405376 oleuptro                MSP          Misspelling                MSP
      76467 Trazodone                   405378 olepbtro                MSP          Misspelling                MSP
      76467 Trazodone                   405380 oleiptro                MSP          Misspelling                MSP
      76467 Trazodone                   405382 oleptrho                MSP          Misspelling                MSP
      76467 Trazodone                   405384 oljptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405386 oleptroo                MSP          Misspelling                MSP
      76467 Trazodone                   405388 olepytro                MSP          Misspelling                MSP
      76467 Trazodone                   405390 oleptero                MSP          Misspelling                MSP
      76467 Trazodone                   405392 olyeptro                MSP          Misspelling                MSP
      76467 Trazodone                   405394 olaeptro                MSP          Misspelling                MSP
      76467 Trazodone                   405396 ooleptro                MSP          Misspelling                MSP
      76467 Trazodone                   405398 olaptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405400 olepwtro                MSP          Misspelling                MSP
      76467 Trazodone                   405402 oleeptro                MSP          Misspelling                MSP
      76467 Trazodone                   405404 oleptrw                 MSP          Misspelling                MSP
      76467 Trazodone                   405406 oluptro                 MSP          Misspelling                MSP
      76467 Trazodone                   405408 olewptro                MSP          Misspelling                MSP
      76467 Trazodone                   405410 oleptiro                MSP          Misspelling                MSP
      76467 Trazodone                   405412 olehptro                MSP          Misspelling                MSP
      76467 Trazodone                   405414 oleptroh                MSP          Misspelling                MSP
;


# ============================================================
#	get all terms for a concept
# ============================================================
;


/*
 * get terms for concept (all)
 */
select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T1.DrugTermID, 
	T1.DrugTermName,
	T2.DrugTermID, 
	T2.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T2.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T1, 
	NLMDrugTerm T2, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where C.DrugConceptID = '10889'
and C.PreferredTermID = T1.DrugTermID
and C.DrugConceptID = T2.DrugConceptID
and T2.DrugTTYID = TT.DrugTTYID
and T2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName DrugTermID DrugTermName                      Abbreviation Name        DrugExternalID
 ------------- ------------------- ---------- ------------ ---------- --------------------------------- ------------ ----------- --------------
         10889 725                      10888 Amphetamine                            10888 Amphetamine                       IN           RxNorm      725
         10889 725                      10888 Amphetamine                            10890 Adderall                          BN           RxNorm      84815
         10889 725                      10888 Amphetamine                            10892 Evekeo                            BN           RxNorm      1600688
         10889 725                      10888 Amphetamine                            10894 Dyanavel                          BN           RxNorm      1720587
         10889 725                      10888 Amphetamine                            10896 Adzenys                           BN           RxNorm      1739804
         10889 725                      10888 Amphetamine                            10898 Mydayis                           BN           RxNorm      1927611
         10889 725                      10888 Amphetamine                            10900 Amphetamine aspartate             PIN          RxNorm      221057
         10889 725                      10888 Amphetamine                            10902 Amphetamine aspartate monohydrate PIN          RxNorm      405812
         10889 725                      10888 Amphetamine                            10904 Amphetamine saccharate            PIN          RxNorm      540810
         10889 725                      10888 Amphetamine                            10906 Amphetamine Sulfate               PIN          RxNorm      81952
         10889 725                      10888 Amphetamine                            10908 Amphetamine                       UNII         FDA         CK833KGX7E
         10889 725                      10888 Amphetamine                          1421784 amphetamione                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421786 ammphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421788 amphdtamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421790 amphetammne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421792 amphetwmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421794 amphuetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421796 amphetaminei                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421798 amphetamiane                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421800 amphaetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421802 ampheteamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421804 amphetamineh                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421806 amphetaymine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421808 amfhetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421810 amphetamiene                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421812 amphatamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421814 amphetymine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421816 emphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421818 amphetamigne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421820 amphetaamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421822 amphetaminue                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421824 amvhetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421826 amphetamhne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421828 amphetumine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421830 ampheotamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421832 amphetamjne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421834 amphetuamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421836 amphetamone                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421838 aemphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421840 imphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421842 amphoetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421844 ampheutamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421846 iamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421848 amphwetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421850 amphetaminwe                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421852 ampheetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421854 amphetemine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421856 umphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421858 amphetimine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421860 amuphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421862 amphehtamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421864 oamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421866 amphetamhine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421868 amphetmine                        MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421870 amphetamune                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421872 amaphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421874 amphetameine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421876 amphetdmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421878 amphetaminye                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421880 amphetamene                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421882 amphetamini                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421884 amphetamihne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421886 amhphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421888 aimphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421890 amphitamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421892 jmphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421894 amphetamiine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421896 amphetamino                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421898 amphetaminew                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421900 amphetaminn                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421902 amphetamineu                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421904 amphhetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421906 aymphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421908 amphetamuine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421910 amiphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421912 amyphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421914 amphetaminw                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421916 yamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421918 amphetaminie                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421920 amphetamwine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421922 amphtamine                        MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421924 amphetajmine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421926 amphetamina                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421928 amphetwamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421930 amphetaminy                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421932 amphetaimine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421934 wamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421936 amphetomine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421938 amphotamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421940 amphetjmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421942 amphetdamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421944 amphethmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421946 amphetamaine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421948 amphetamiune                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421950 amphetamwne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421952 amphetamgne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421954 amphetahmine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421956 awmphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421958 amphytamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421960 amphetaminne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421962 amphetaemine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421964 omphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421966 amwphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421968 ampheatamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421970 eamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421972 amphwtamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421974 amphetaminh                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421976 amphetamyne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421978 amphetamin                        MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421980 amphetaminhe                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421982 amphedtamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421984 amphetamane                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421986 aumphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421988 amphetawmine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421990 ampheytamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421992 amophetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421994 ajmphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421996 aamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1421998 amphetmmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422000 amphetamoine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422002 amphyetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422004 amphethamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422006 amphetaumine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422008 uamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422010 amphetamiwne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422012 amphetammine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422014 amphetamne                        MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422016 amphutamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422018 amphetaminey                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422020 amphetaminea                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422022 amphettamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422024 amephetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422026 amphetaminee                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422028 amphhtamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422030 amphttamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422032 amphetamijne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422034 amphetamnne                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422036 amphetaminoe                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422038 amphetamiyne                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422040 amphetaomine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422042 amphettmine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422044 aomphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422046 amphetoamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422048 amphetamyine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422050 jamphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422052 amphejtamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422054 ymphetamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422056 amphetyamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422058 amphietamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422060 amphewtamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422062 amphjtamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422064 ampheitamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422066 amphedamine                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422068 ahmphetamine                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422070 amphetaminu                       MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422072 amphetaminae                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422074 amphetamineo                      MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422076 awderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422078 adderala                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422080 addwrall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422082 adderallu                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422084 addyerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422086 addereall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422088 adderalo                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422090 oadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422092 adderael                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422094 adderail                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422096 addrrall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422098 addherall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422100 aodderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422102 addarall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422104 aydderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422106 adderaall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422108 adderahll                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422110 adderajll                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422112 adderallw                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422114 adderajl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422116 adderally                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422118 edderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422120 adderull                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422122 ahderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422124 adderll                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422126 adderoall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422128 iadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422130 auderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422132 aduerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422134 audderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422136 adderhll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422138 eadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422140 adierall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422142 adderaull                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422144 aadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422146 addeirall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422148 adderrll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422150 wadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422152 adderaoll                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422154 uadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422156 aederall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422158 adderaell                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422160 adyerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422162 addhrall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422164 adderjll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422166 adderallh                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422168 addrall                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422170 udderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422172 awdderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422174 adderyall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422176 idderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422178 adderal                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422180 adderoll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422182 adwerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422184 adderallo                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422186 adeerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422188 adderwll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422190 adderrall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422192 addorall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422194 adderale                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422196 addwerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422198 yadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422200 jdderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422202 adderhall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422204 addearall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422206 adderayl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422208 ydderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422210 addehrall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422212 aiderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422214 odderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422216 ahdderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422218 addaerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422220 adderwall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422222 addoerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422224 addurall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422226 adderaol                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422228 aidderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422230 adderalh                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422232 jadderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422234 aaderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422236 adderaal                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422238 adderaill                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422240 adderalle                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422242 adderalw                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422244 adderaly                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422246 adderyll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422248 adderalli                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422250 adderawll                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422252 adderali                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422254 adderaul                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422256 addyrall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422258 adaerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422260 addewrall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422262 ayderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422264 addeerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422266 adderayll                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422268 adderawl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422270 adderiall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422272 adderuall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422274 adduerall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422276 addirall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422278 aderall                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422280 atderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422282 adderahl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422284 adterall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422286 adderalu                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422288 addeorall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422290 adherall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422292 adderill                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422294 adderalla                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422296 addierall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422298 adderell                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422300 addeurall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422302 aoderall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422304 aedderall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422306 adoerall                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422308 addeyrall                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422310 odzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422312 adznys                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422314 adzenysz                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422316 adzenysw                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422318 adzenyus                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422320 adzenysi                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422322 adzeonys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422324 adzewnys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422326 adzenyws                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422328 adzenes                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422330 jdzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422332 yadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422334 adzenays                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422336 adzenwys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422338 wadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422340 adzens                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422342 adzjnys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422344 adzenyhs                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422346 adzenysy                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422348 aduzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422350 adzenysa                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422352 adizenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422354 adzenus                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422356 adzaenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422358 adzynys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422360 adzeunys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422362 uadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422364 ydzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422366 adzeynys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422368 adzenyse                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422370 idzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422372 adzwnys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422374 adezenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422376 oadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422378 adczenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422380 audzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422382 awzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422384 adzenjs                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422386 aydzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422388 adzeniys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422390 adznnys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422392 adzuenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422394 adzznys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422396 adzenyas                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422398 atdzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422400 adsenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422402 adzeanys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422404 adzegnys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422406 edzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422408 adcenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422410 udzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422412 aadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422414 adzenyys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422416 adzehnys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422418 jadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422420 adzyenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422422 adzzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422424 adazenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422426 adzenws                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422428 adzennys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422430 iadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422432 adzinys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422434 adjzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422436 awdzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422438 adzenhys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422440 ahdzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422442 aidzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422444 adzeinys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422446 adyzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422448 adzwenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422450 adzenyss                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422452 adzoenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422454 adzonys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422456 adtzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422458 adzenyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422460 adzenss                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422462 adzunys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422464 adzeneys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422466 adzienys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422468 adzenas                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422470 adzenyes                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422472 adzgnys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422474 adhzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422476 atzenys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422478 adzenysu                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422480 addzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422482 adozenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422484 adzenyz                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422486 adzenos                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422488 adzenhs                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422490 adzenyos                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422492 aedzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422494 adzenns                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422496 adzenyjs                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422498 aodzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422500 adwzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422502 adzanys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422504 adzeenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422506 adzejnys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422508 eadzenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422510 adszenys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422512 adzenuys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422514 adzenis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422516 adzenyso                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422518 adzenoys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422520 dyuanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422522 dyanavvl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422524 duyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422526 dyyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422528 dyanuavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422530 doanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422532 dyanavehl                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422534 dyanawvel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422536 dyanaavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422538 dyanavvel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422540 danavel                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422542 dyaenavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422544 dyaynavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422546 dynavel                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422548 dtyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422550 doyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422552 dyanvel                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422554 dyannavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422556 dyanahvel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422558 dyanavyel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422560 dyaunavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422562 dyeanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422564 dyanavil                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422566 dyanavuel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422568 dywnavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422570 dyanuvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422572 dyanhavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422574 dyajnavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422576 dynnavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422578 dyanaovel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422580 dyanevel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422582 dyanaval                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422584 dayanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422586 wdyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422588 dyanavyl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422590 dyanaveol                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422592 dyanauvel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422594 dyanavul                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422596 dyaonavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422598 dyanavwel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422600 dyanayvel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422602 dyanavjl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422604 dyunavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422606 dyanaveyl                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422608 dyanavela                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422610 diyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422612 dhanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422614 hdyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422616 dyanavelo                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422618 dyanafel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422620 dyjnavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422622 dyanoavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422624 dyanwvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422626 dyanaivel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422628 dyanavl                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422630 dyanaveal                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422632 dyanwavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422634 dywanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422636 dyanavely                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422638 dyanaviel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422640 dyainavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422642 dyanavol                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422644 dwanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422646 dyinavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422648 dyanavhel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422650 dtanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422652 ddanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422654 dyanivel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422656 dyahnavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422658 dyanaveel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422660 tyanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422662 dyanavael                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422664 dyanaveul                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422666 dyynavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422668 dianavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422670 dygnavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422672 dyannvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422674 dyanavelh                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422676 dyawnavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422678 dyanaveil                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422680 dyagnavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422682 dyoanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422684 dyianavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422686 deyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422688 dyanyavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422690 dyanavewl                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422692 dyanvvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422694 duanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422696 dyanavwl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422698 dyaniavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422700 dyanavhl                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422702 tdyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422704 dyanavejl                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422706 dwyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422708 ddyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422710 deanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422712 dyenavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422714 dhyanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422716 dyaneavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422718 dyanavll                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422720 dyhnavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422722 dyanavele                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422724 daanavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422726 dyanaveli                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422728 dyanavoel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422730 dyanaevel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422732 dyanovel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422734 dyanhvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422736 dyanavelu                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422738 dyanavelw                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422740 dyanavell                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422742 dyonavel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422744 dyaanavel                         MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422746 dyanyvel                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422748 evejkeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422750 wevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422752 evekkeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422754 evakeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422756 evekwo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422758 evekew                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422760 evekyeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422762 evekeoh                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422764 eveakeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422766 evekeeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422768 evekeoe                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422770 evekee                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422772 eveokeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422774 evwekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422776 eviekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422778 ievekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422780 evekheo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422782 jevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422784 avekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422786 evekeou                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422788 evekeu                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422790 eveqeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422792 evekeyo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422794 evekeio                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422796 evekeoi                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422798 ehvekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422800 uvekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422802 evhkeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422804 evekao                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422806 evekey                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422808 evwkeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422810 efekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422812 evokeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422814 eivekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422816 eovekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422818 evekeh                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422820 evvkeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422822 eveckeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422824 eveykeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422826 uevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422828 oevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422830 evekjo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422832 evoekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422834 eavekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422836 evekweo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422838 evyekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422840 eveekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422842 yevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422844 evekaeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422846 ivekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422848 evegeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422850 evekoo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422852 eveikeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422854 evukeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422856 evykeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422858 evckeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422860 evkkeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422862 jvekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422864 evekewo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422866 evikeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422868 evewkeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422870 evvekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422872 euvekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422874 evekueo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422876 evekjeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422878 evekio                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422880 aevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422882 evekeow                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422884 evuekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422886 evekeao                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422888 eveukeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422890 eevekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422892 yvekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422894 evekei                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422896 evekieo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422898 evjkeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422900 evekoeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422902 evekeuo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422904 evekho                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422906 ovekeo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422908 evekyo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422910 evhekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422912 evekeoo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422914 eyvekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422916 evekko                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422918 ewvekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422920 evekeoa                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422922 evekea                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422924 evekeoy                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422926 evehkeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422928 evekuo                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422930 evaekeo                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422932 mydhayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422934 mydeyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422936 wmydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422938 mywdayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422940 moydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422942 mydoyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422944 mydaiyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422946 mydiayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422948 mydyayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422950 mydayws                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422952 midayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422954 mydayisi                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422956 mydauyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422958 mydaais                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422960 mhdayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422962 mydwayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422964 modayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422966 mydayss                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422968 mydeayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422970 maydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422972 mydayais                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422974 mydayiys                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422976 mmydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422978 mydayes                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422980 mytayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422982 mydoayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422984 mydaois                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422986 mydhyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422988 mydayiz                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422990 mdayis                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422992 myhdayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422994 mydayisz                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422996 miydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1422998 mydaiis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423000 muydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423002 mydayeis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423004 myodayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423006 madayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423008 mydayiis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423010 mudayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423012 mydayihs                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423014 myduyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423016 mydayhs                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423018 mydwyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423020 mydtyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423022 mmdayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423024 mydayiws                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423026 mydaeis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423028 mydayisy                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423030 mydtayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423032 mydayisa                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423034 myudayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423036 mydaayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423038 myddyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423040 hmydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423042 mydayias                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423044 mydyis                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423046 mydayos                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423048 myddayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423050 mydayjs                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423052 medayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423054 mydaoyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423056 mydauis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423058 myduayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423060 myydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423062 mtdayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423064 mydawyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423066 myedayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423068 mydayas                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423070 mydayois                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423072 mwdayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423074 mytdayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423076 meydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423078 mydayiss                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423080 mydayios                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423082 mydais                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423084 mydayius                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423086 myidayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423088 mydayijs                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423090 myadayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423092 mydayus                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423094 mydayise                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423096 mydayisw                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423098 mydayys                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423100 mydayies                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423102 mydaywis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423104 mwydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423106 mddayis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423108 mydays                            MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423110 mydaeyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423112 mydayyis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423114 mydyyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423116 mydayuis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423118 mydawis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423120 mydayisu                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423122 mydayiso                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423124 mydiyis                           MSP          Misspelling 
         10889 725                      10888 Amphetamine                          1423126 mhydayis                          MSP          Misspelling 
         10889 725                      10888 Amphetamine                          2071803 Amphetamine                       PV           NFLIS       
         10889 725                      10888 Amphetamine                          2071805 AMPHETAMINE                       SY           NFLIS       
         10889 725                      10888 Amphetamine                          2080995 Amphetamine                       PV           DEA         1100
         10889 725                      10888 Amphetamine                          2080997 Dexedrine                         SY           DEA         
         10889 725                      10888 Amphetamine                          2080999 Adderall                          SY           DEA         
         10889 725                      10888 Amphetamine                          2081001 Obetrol                           SY         
;

/*
 * get terms for concept (specific term type)
 */
select
	distinct
	C.DrugConceptID,
	C.DrugSourceConceptID,
	T1.DrugTermID, 
	T1.DrugTermName,
	T2.DrugTermID, 
	T2.DrugTermName,
	TT.Abbreviation,
	TS.Name,
	T2.DrugExternalID
from 
	NLMDrugConcept C, 
	NLMDrugTerm T1, 
	NLMDrugTerm T2, 
	NLMDrugTermType TT, 
	NLMDrugAuthoritativeSource TS
where C.DrugConceptID = '32458'
and C.PreferredTermID = T1.DrugTermID
and C.DrugConceptID = T2.DrugConceptID
and T2.DrugTTYID = TT.DrugTTYID
and T2.DrugAuthoritativeSourceID = TS.DrugAuthoritativeSourceID
and TT.Abbreviation = 'BN'
;
 DrugConceptID DrugSourceConceptID DrugTermID DrugTermName DrugTermID DrugTermName Abbreviation Name   DrugExternalID
 ------------- ------------------- ---------- ------------ ---------- ------------ ------------ ------ --------------
         32458 448                      32457 Ethanol           32459 Avagard      BN           RxNorm 1089997
         32458 448                      32457 Ethanol           32461 Prevail      BN           RxNorm 1098216
         32458 448                      32457 Ethanol           32463 BD Persist   BN           RxNorm 1312492
;