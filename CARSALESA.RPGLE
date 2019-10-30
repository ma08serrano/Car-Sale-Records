000100181130      * Include the required LongRange and EZI definitions                                          
000101181130                                                                                                    
000102181113     H BNDDIR('LRNGSRV') DFTACTGRP(*No) ACTGRP(*Caller)                                             
000103181113     H BNDDIR('EZISERVICE')                                                                         
000104181130                                                                                                    
000105181130     F* Table is filled with data from   Customer Enter the File spec                               
000106181130                                                                                                    
000107181130     FCAR_SALES IF   E             Disk    Rename (CAR_SALES:CARSALESr)                             
000108181130                                                                                                    
000109181113      * Standard include for LRNG support function prototypes                                       
000110181113      /INCLUDE SOURCEDEMO,DEMOCOMMON                                                                
000111181113      * Standard include for LRNG support function prototypes                                       
000112181113      /INCLUDE QRPGLESRC,EZISERVICE                                                                 
000113181113      * Standard include for LRNG support function prototypes                                       
000114181113      /INCLUDE LRNGSOURCE,LRNGCOMMON                                                                
000126181130     D Index           s             10i 0                                                          
000127181129     D ArrayEntries    c                   20                                                       
000128181201                                                                                                    
000129181113      * Prototype for call to build Html                                                            
000145181130     D CARSALESA       pi                                                                           
000146181130     D dentries                      10i 0                                                          
000147181202     D didnumber                      9s 0 Dim(ArrayEntries)                                        
000148181201     D dcompany                       8a   Dim(ArrayEntries)                                        
000149181130     D dcalendar                     10a   Dim(ArrayEntries)                                        
000150181201     D dactual                        2s 0 Dim(ArrayEntries)                                        
000151181201     D dprevious                      2s 0 Dim(ArrayEntries)                                        
000152181201     D dcurrent                       2s 0 Dim(ArrayEntries)                                        
000153181130     D outHTML                    65000a   Varying                                                  
000156181130                                                                                                    
000157181130     D Local           Ds                                                                           
000159181130     D                               10I00 Inz(0)                                                   
000160181130     D   Row                         10I00 Inz(0)                                                   
000170181113      /Free                                                                                         
000171181130                                                                                                    
000172181130       Exsr Setup_MyTable;                                                                          
000182181130       //==============================================================                             
000183181130       // Create the HTML content                                                                   
000184181130       //==============================================================                             
000185181130       // Do the headings                                                                           
000186181130       Exsr Heading;                                                                                
000187181130       // Do the details                                                                            
000188181130       For Index = 1 to dentries;                                                                   
000189181130         Exsr Details;                                                                              
000190181130       Endfor;                                                                                      
000191181130       // Do the footer                                                                             
000192181130       Exsr Footer;                                                                                 
000193181130       // Convert final result from code page 37 to current job's code page (aka 0).                
000194181130       outHTML = EZI_TranslateScripting(37:0:outHTML);                                              
000195181130       // Finito                                                                                    
000196181130       return;                                                                                      
000197181130                                                                                                    
000200181130       BegSr Setup_MyTable;                                                                         
000223181130         Row = 0;                                                                                   
000224181130         Read CAR_SALES;                                                                            
000225181130         Dow (NOT %EOF);                                                                            
000226181130           Row += 1;                                                                                
000227181202           didnumber(Row) = %DEC(CARID);                                                            
000228181130           dcompany(Row) = COMPANY;                                                                 
000229181130           dcalendar(Row) = %CHAR(DATE);                                                            
000230181130           dactual(Row) = %DEC(ACTUA00001);                                                         
000231181130           dprevious(Row) = %DEC(PREV_00001);                                                       
000232181130           dcurrent(Row) = %DEC(CURR_00001);                                                        
000233181130                                                                                                    
000234181130           Read CAR_SALES;                                                                          
000235181130         ENDDO;                                                                                     
000237181130       ENDSR;                                                                                       
000238181130                                                                                                    
000239181113       //==============================================================                             
000240181113       //  Generate the HEAD and SCRIPT section of the HTML                                         
000241181113       //==============================================================                             
000242181113       Begsr Heading;                                                                               
000243181113         outHTML = '<html><head>';                                                                  
000244181113         outHTML += '<script type="text/javascript"'                                                
000245181113                  + ' src="https://www.google.com/jsapi">'                                          
000246181113                  + '</script>';                                                                    
000247181113         outHTML += '<script type="text/javascript">';                                              
000248181113         outHTML +=   'google.load("visualization", "1"'                                            
000249181113                   +  ', { packages:["corechart"] } );';                                            
000250181113         outHTML += 'google.setOnLoadCallback(drawChart);';                                         
000251181113         outHTML += 'function drawChart() {';                                                       
000252181113         outHTML += 'var data = google.visualization'                                               
000253181115                 +  '.arrayToDataTable([["Task", "..."],';                                          
000254181113        Endsr;                                                                                      
000255181130                                                                                                    
000256181113       //==============================================================                             
000257181113       //  Add Details to the chart function                                                        
000258181113       //==============================================================                             
000259181113        Begsr Details;                                                                              
000260181130          outHTML += '["' + dcompany(index) + '", ' +                                               
000261181130             %char(dcurrent(index)) + '],';                                                         
000262181113        Endsr;                                                                                      
000263181113       //==============================================================                             
000264181113       // Generate the BODY of the HTML page                                                        
000265181113       //==============================================================                             
000266181113       Begsr Footer;                                                                                
000267181113           outHTML += ']);';                                                                        
000268181113           outHTML += 'var options = {';                                                            
000269181113           outHTML += 'title:"Total Car Sales" };';                                                 
000270181113           outHTML += 'var chart = new google.visualization'                                        
000271181115                       + '.BarChart(document.' +                                                    
000272181113                       'getElementById("chart_div"));';                                             
000273181113           outHTML += 'chart.draw(data, options); }';                                               
000274181113           outHTML += '</script></head>';                                                           
000275181113           outHTML  += '<body>';                                                                    
000276181113           outHTML += '<div id="chart_div" style="width:'                                           
000277181113                    + '900px; height: 500px;"></div>';                                              
000278181113           outHTML += '</body></html>';                                                             
000279181113        Endsr;                                                                                      
000280181113      /End-free                                                                                     
000281181113                                                                                                    
