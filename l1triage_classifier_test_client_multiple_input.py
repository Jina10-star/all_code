import requests
import base64
import time
import json



#url_address = "http://127.0.0.1:5000"
#url_address = "https://127.0.0.1"
#url_address = "http://dca1-up-ml-t01"
url_address = "https://uipathmltest.corp.uber.com"
#url_address = "http://dca1-ic-d-aby01:5000"
#url_address = "https://uipathmldev.corp.uber.com"
#url_address="https://uipathmlprod.corp.uber.com"
#url_address="https://192.168.108.132:443"
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier'
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier_component_multi'
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier_tier_type_1_multi'
ENDPOINT = '/iacoe_ocr/l1_triage_classifier_tier_type_2_multi'
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier_michelangelo_batch_multi'
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier_michelangelo'
#ENDPOINT = '/iacoe_ocr/l1_triage_classifier_michelangelo_multi'


url = url_address + ENDPOINT


###############L1 traige inputs#############
id1=0
label1='tier_type_2'
projectid1="L1triage"
modelid1="tm20221111-103934-JXCCMDZD-XSJRDN"
summary1='Uber Oracle Concurrent Program Runtime Alert!!'
description1='Hi Ram, Can we please grant uberAD/natalia.galvez and uberAD/cooney access to the BTA User Group security group in TM1 Planning.Prod & Planning.UAT? He is a non-Finance user, so we will have to manually load him in. If possible - can we do this before 9am PST tomorrow? Thank you and hope you guys had a great weekend,Ryan'
###############L1 traige inputs#############
id2=0
label2='tier_type_2'
projectid2="L1triage"
modelid2="tm20221111-104453-PDVABGLH-FIMDPP"
summary2='Oracle folder access required'
description2='Hi Chaithanya, Greetings! I have joined the Vendor master team in the month of November 2020, As a part of my activities, I need to have access of the below folders in the Oracle tool to perform my role. Please do the necessary and help me in getting the access. |AU Uber AP Supplier Entry| |AU Uber Pacific V.O.F. AP Supplier Entry| |AU Uber Pacific Hldg Pty AP Supplier Entry| |AU Rasier Pacific V.O.F. AP Supplier Entry| |AU Uber Australia Hldg Pty AP Supplier Entry| |AU Jump AP Supplier Entry| |AU Routematch Software Pty Ltd AP Supplier Entry| |AT Uber AP Supplier Entry| |BD Uber AP Supplier Entry| |BE Uber AP Supplier Entry| |BE Jump AP Supplier Entry| |BE Uber Eats AP Supplier Entry| |BM Uber AP Supplier Entry| |BG Uber AP Supplier Entry| |BG SD AP Supplier Entry| |CA Uber AP Supplier Entry| |CI Uber AP Supplier Entry| |HR Uber AP Supplier Entry| |CZ Uber AP Supplier Entry| |DK Uber AP Supplier Entry| |DK SD AP Supplier Entry| |EG Uber AP Supplier Entry| |EG Uber Misr AP Supplier Entry| |EG Uber Technologies AP Supplier Entry| |EE Uber AP Supplier Entry| |FI Uber AP Supplier Entry| |FR Uber AP Supplier Entry| |FR Hinter AP Supplier Entry| |FR Fast Driver AP Supplier Entry| |FR Partner Support AP Supplier Entry| |FR Jump AP Supplier Entry| |FR Uber Freight AP Supplier Entry| |FR Uber Software AP Supplier Entry| |DE SafeDriver AP Supplier Entry| |DE Uber AP Supplier Entry| |DE Limo Royal AP Supplier Entry| |DE Jump Bicycles GmbH AP Supplier Entry| |DE Uber Freight AP Supplier Entry| |GH Uber AP Supplier Entry| |GB Jump Bicycles UK AP Supplier Entry| |GB Uber AP Supplier Entry| |GB Uber Eats AP Supplier Entry| |GB Brittania AP Supplier Entry| |GB Scot Ltd AP Supplier Entry| |GB Xub LTD AP Supplier Entry| |GR Uber AP Supplier Entry| |HU Uber AP Supplier Entry| |IE Uber AP Supplier Entry| |IE Routematch Software Ltd AP Supplier Entry| |IE Uber COE AP '
#HFM 
###############L1 traige inputs#############
id3=0
label3='tier_type_2'
projectid3="L1triage"
modelid3="tm20221111-105520-WOLSWOAI-AKXSPY"
summary3='Oracle folder access required'
description3='Hi Team,Please investigate why the below invoice has a different value in OTM compared to the invoice.Please find the attached file and below screenshot for your reference.mage.png|thumbnail!' 
 



payload_1={"id": id1,"label": label1,"projectid": projectid1,"summary": summary1,"description": description1}
payload_2={"id":id2,"label":label2,"projectid":projectid2,"id": id2,"label": label2,"projectid": projectid2,"summary": summary2,"description": description2}
payload_3={"id":id3,"label":label3,"projectid":projectid3,"id": id3,"label": label3,"projectid": projectid3,"summary": summary3,"description": description3}
payload=[payload_1,payload_2,payload_3]
################L1 traige inputs#############
payload_22={'l1triage_input_data':[{"summary":summary1,"description":description1},
            {"summary":summary2,"description":description2},
            {"summary":summary3,"description":description3}]}
payload_23={'l1triage_inpu_data':[{"summary":" ","description":" "},
            {"summary":" ","description":" "},
            {"summary":" ","description":" "}]}
print(payload_22)
payload_11={'l1triage_input_data':[{"id":id1,"label":label1,"projectid":projectid1,"summary":summary1,"description":description1},
            {"id":id2,"label":label2,"projectid":projectid2,"summary":summary2,"description":description2},
            {"id":id3,"label":label3,"projectid":projectid3,"summary":summary3,"description":description3}]}

#data={"summary":"JSON 210 ERRORS - TRICOR BRAUN","description":"== Created by JEMH via e-mail from: <POKLI@KLEINSCHMIDT.COM> == CUSTOMER_NAME: TricorBraun - USINVOICE_NUMBER: 8041382599INVOICE_NUMBER: 1007776816INVOICE_NUMBER: 4718348161ERROR: NULLS FOUND IN JSON ADDRESS"}
    
t_start=time.time()
try:
    response = requests.post(url, json=payload_23, verify=False)
    #response = requests.post(url, data=payload_11, verify=False)
    print(response.text)
    t_end=time.time()
    print(t_end-t_start)
except requests.ConnectionError as e:
    print("OOPS!! Connection Error. Make sure you are connected to Internet. Technical Details given below.\n")
    print(str(e))            
    #renewIPadress()
    #continue
except requests.Timeout as e:
    print("OOPS!! Timeout Error")
    print(str(e))
    #renewIPadress()
    #continue
except requests.RequestException as e:
    print("OOPS!! General Error")
    print(str(e))
    #renewIPadress()
    #continue
except KeyboardInterrupt:
    print("Someone closed the program")


