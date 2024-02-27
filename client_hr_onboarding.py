import requests
import base64
import json
#import cv2
import numpy as np
import os

from ast import literal_eval

APIKEY = 'AIzaSyCGSGCUuN4PH576zqRqk_hHWiBd1mN7SwA'

#url_address = "http://127.0.0.1:5000"
#url_address="https://uipathmlprod.corp.uber.com"
#url_address = "http://0.0.0.0:5000"
url_address = "https://uipathmldev.corp.uber.com"

ENDPOINT = '/iacoe_ocr/frm18/detectsignature'
url = url_address + ENDPOINT

#imgs_path = r'/Users/hsingh151/Downloads/HR_SIGNATURE_DETECTION/scripts/image outputs'

# /Volumes/Signature_Page/test
apikey_bytes = str(APIKEY).encode()
apikey_base64 = base64.b64encode(apikey_bytes)

# path = r'/Users/mdevar2/Documents/hr_onboarding/test_Images_new'
#path = r'/Users/mdevar2/Downloads/FRM8/test'
#path  = r'/Users/mdevar2/Downloads/FRM8/test'
#path  = r'/Users/mdevar2/Downloads/FRM8 2/test'
path = r"//corp.uber.com/rpa/UiPath/Test/FRM5/Signature_Page/test2/"
#path = r"//corp.uber.com/rpa/UiPath/Test/FRM5/Signature_Page/test/"
#path = r'C:\Users\hsingh151-adm\Downloads\hr_onboarding_test\pdf_files'
#print(path)
#print("Client File path", path)
#\\corp.uber.com\rpa\UiPath\test\FRM5\Signature_Page\test
#geo = "india"
#geo = "philippines"
#geo = "netherlands"

# doctype = "internaltransfer"
# doctype = "addendum"
#doctype = "hp"
doctype = "dfs"
# doctype = "rsu"
# doctype = "crsu"

# print(type(imgs_base64_json))((()))

payload = {'pdf_path': path, 'doctype': doctype, 'apikey_base64': apikey_base64}
print("payload: ", payload)
#response = requests.post(url, data=payload, verify=False)

#print(response)

    # with open('response.txt', 'w', encoding='utf-8') as f:
    #     f.write(str(response.text.encode('utf-8')))

#json_data = json.loads(response.text.encode('utf-8'))

#print(json_data)

try:
    #response = requests.post(url, json=payload_2, verify=False)
    response = requests.post(url, data=payload, verify=False)
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