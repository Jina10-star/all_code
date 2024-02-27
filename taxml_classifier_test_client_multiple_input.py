import requests
import base64
import time
import json

# url = "http://127.0.0.1:5000/iacoe_ocr/text_classifier"


#url_address = "http://127.0.0.1:5000"
#url_address = "https://127.0.0.1"
# url_address = "http://dca1-up-ml-t01"
#url_address = "https://uipathmltest.corp.uber.com"
# url_address = "http://dca1-ic-d-aby01:5000"
#url_address = "https://uipathmldev.corp.uber.com"
url_address="https://uipathmlprod.corp.uber.com"
#url_address="https://192.168.108.132:443"
#ENDPOINT = '/iacoe_ocr/taxml_expansion_classifier'
#ENDPOINT = '/iacoe_ocr/taxml_expansion_classifier_multi'
#ENDPOINT = '/iacoe_ocr/taxml_classifier'
ENDPOINT = '/iacoe_ocr/taxml_classifier_multi'
#ENDPOINT = '/iacoe_ocr/taxml_classifier_michelangelo'
#ENDPOINT = '/iacoe_ocr/taxml_classifier_michelangelo_multi'
url = url_address + ENDPOINT

# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\pipeline\Uber_IACOE_OCR_ML_Pipeline\test_client\raw_text.txt"
# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\pipeline\Uber_IACOE_OCR_ML_Pipeline\test_client\3453648706_Lumper_rawExtract.txt"
# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\freight_billing_trials\Ratecon, ACK and supporting docs-20200710T084809Z-001\Ratecon, ACK and supporting docs\ocr_results_for_all\0_1727377753_invoice.pdf.jpg_raw_text.txt"
# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\shipper_platform\format-1-out\final_data\test\0_1482655191-PROOF_OF_DELIVERY.PDF.jpg_raw_text.txt"
# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\shipper_platform\Unknown\final_data_2\0_5168563042_bol.pdf.jpg_raw_text.txt"
# text_file_path = r"C:\Users\ksaluj1\Documents\work\dev\shipper_platform\Unknown\final_data_2\4253092107-PROOF_OF_DELIVERY.JPG_raw_text.txt"
# text_file_path = "/Users/ssingh355/code/invoice_processing/data/check_confidence/data/0_ICNME-MCRN-00049-008_BPO_CNX_MXO_LATAM US & CA GVD_Feb-Mar 2021.pdf.jpg_raw_text.txt"
# text_file_path = "/Users/ssingh355/code/invoice_processing/data/check_confidence/data/0_ICNME-MCRN-00049-007_BPO_CNX_MXO_LATAM US & CA GVD_Feb-Mar 2021 (1).pdf.jpg_raw_text.txt"
# text_file_path = "ab-format-1-test-file.txt"
# text_file_path = "ab-unknown-test-file.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\Dev\IACOE OCR\test_samples\kraft-foods\text_classifier_test_samples\1_5121195053.pdf.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\Dev\IACOE OCR\test_samples\kraft-foods\text_classifier_test_samples\6197196406-PROOF_OF_DELIVERY.JPG_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\nestle\classifier_test\0_3241860130.PDF.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\nestle\classifier_test\2_7268911886-PROOF_OF_DELIVERY.PDF.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\uipath\dev\IACOE OCR\test_samples\refresco\0_1191317334-PROOF_OF_DELIVERY.PDF.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\chep\classifier_test\format-1\3937502736-PROOF_OF_DELIVERY.JPG_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\chep\classifier_test\others\0_6291485681.pdf.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\p2p_invoice\classifier_test_samples\0_019_2270024142.pdf.jpg_raw_text.txt"
# text_file_path = r"\\corp.uber.com\rpa\UiPath\dev\IACOE OCR\test_samples\p2p_invoice\concentrix\0_019_CUSA-SINV-027864.pdf.jpg_raw_text.txt"
# text_file_path = "/Users/ksaluj1/Documents/work/dev/cocacola_bol/Coca-cola delivery slip/imgs/others/0_1208675934.pdf.jpg_raw_text.txt"
# text_file_path = "/Users/ksaluj1/Documents/work/dev/invoice_p2p_pilot/classifier_workout/dataset/imgs_filtered/WIPRO LIMITED-V1/test/0_030_511008155.pdf.jpg_raw_text.txt"
# text_file_path = "/Users/ksaluj1/Documents/work/dev/invoice_p2p_pilot/classifier_workout/dataset/imgs_filtered/CONCENTRIX CORPORATION US-V1/test/0_029_CUSA-SINV-028106.pdf.jpg_raw_text.txt"
# text_file_path = "/Users/ssingh355/code/invoice_processing/ip_classifier/imgs_filtered_APAC/Taxback International-V1/test/0_001_970023467.pdf.jpg_raw_text.txt"

# doctype = "Freight-Billing"
# doctype = "Shipper-Platform"
# doctype = "AB"
# doctype = "Krafts-Foods"
# doctype = "Nestle"
# doctype = "Chep"
# doctype = "Refresco"
# doctype = "Cocacola"
# doctype = "Invoice-Processing"
# doctype = "Invoice-Processing-nam"
# doctype = "Invoice-Processing-canada"
# doctype = "Invoice-Processing-apac"
################taxml inputs#############
#""taxml_input_data"":[{""item"":""Lay's Potato Chips Sour Cream & Onion 7.75 oz Bag"",""description"":""\N"",""establishment_type"":""LIQUOR""}]}
id1=1
label1='prod'
projectid1="taxml_classification"
item1='Hot Pockets'
description1='Choose between Pepperoni and Ham & Cheddar'
establishment_type1='CONVENIENCE'

id1=1
label1='prod'
projectid1="taxml_classification"
name1='Old Trapper Peppered Beef Jerky 10oz'
description1='Old Trapper Peppered Jerky is your flavor. Its seasoned with our own quality mix of spices'
establishment_type1='CONVENIENCE'

id2=1
label2='prod'
projectid2="taxml_classification"
name2='Jameson Irish Whiskey.1.75L Bottle Size'
description2=''
establishment_type2='GROCERY'

id3=1
label3='prod'
projectid3="taxml_classification"
name3="Lay's Potato Chips Sour Cream & Onion 7.75 oz Bag"
description3=''
establishment_type3="LIQUOR"

id4=1
label4='prod'
projectid4="taxml_classification"
name4='Classics Combinations    '
description4='Hand-breaded Calamari, Mozzarella Marinara and  Four-Cheese & Sausage Stuffed Mushrooms. Served with a  side of our marinara sauce'
establishment_type4='DEFAULT'

name5='Svalya Rossiyskiy Cheese Sliced 50% (150 gm)'
description5=''
establishment_type5='DEFAULT'

name6='Clos Du Bois Zinfandel'
description6='Black cherry red color, this Zinfandel tempts with aromas of ripe plum, blackberry, and hints of baking spice. Full bodied and fruit forward with soft, supple tannins, and flavors of juicy blackberry with light hints of toasted oak.'
establishment_type6='GROCERY'

name7="Hr Tandori Roti"
description7=''
establishment_type7="GROCERY"

name8='FIRE BALL WHISKEY'
description8=''
establishment_type8='GROCERY'
#CAT_PREPACKAGED_FOOD_CHEESE:723
#CAT_WINE:534
#CAT_PREPACKAGED_FOOD,TEMP_HEATED:106,1
#CAT_LIQUOR:535
payload={'taxml_input_data':[{"item":name5,"description":description5,"establishment_type":establishment_type5},
            {"item":name6,"description":description6,"establishment_type":establishment_type6},
            {"item":name7,"description":description7,"establishment_type":establishment_type7},
            {"item":name8,"description":description8,"establishment_type":establishment_type8}]}
print(payload)
payload_1={'taxml_input_data':[{"id":id1,"label":label1,"projectid":projectid1,"item":name1,"description":description1,"establishment_type":establishment_type1},
            {"id":id2,"label":label2,"projectid":projectid2,"item":name2,"description":description2,"establishment_type":establishment_type2},
            {"id":id3,"label":label3,"projectid":projectid3,"item":name3,"description":description3,"establishment_type":establishment_type3},
            {"id":id4,"label":label4,"projectid":projectid4,"item":name4,"description":description4,"establishment_type":establishment_type4}]}
payload_2={'taxml_input_data':[{"item":name5,"description":description5,"establishment_type":establishment_type5},
            {"item":name6,"description":description6,"establishment_type":establishment_type6},
            {"item":name7,"description":description7,"establishment_type":establishment_type7},
            {"item":name8,"description":description8,"establishment_type":establishment_type8}]}


#data={'item_name':" ",'description':" ",'establishment_type':" "}
#payload_1={"id": id1,"label": label1,"projectid": projectid1,"item": item1,"description": description1,"establishment_type":establishment_type1}
try:
    response = requests.post(url, json=payload, verify=False)
    #response = requests.post(url, data=payload_1, verify=False)
    print(response.text)

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

