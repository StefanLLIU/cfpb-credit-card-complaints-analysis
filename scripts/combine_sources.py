"""Validate two CFPB credit-card exports and combine without changing source values."""
import argparse
import csv
from pathlib import Path
from datetime import datetime

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input-2024',required=True,type=Path)
    p.add_argument('--input-2025',required=True,type=Path)
    p.add_argument('--output',required=True,type=Path)
    a=p.parse_args()
    if a.output.exists():p.error('Output exists; choose a new path to preserve it.')
    records=[];ids=set();headers=None
    for year,path in [(2024,a.input_2024),(2025,a.input_2025)]:
        count=0
        with path.open(encoding='utf-8-sig',newline='') as f:
            r=csv.DictReader(f)
            if headers is None:headers=r.fieldnames
            if r.fieldnames!=headers:raise ValueError('Input column names/order differ')
            if 'Source Year' in headers:raise ValueError('Expected original exports, not previously combined files')
            for row in r:
                if None in row or any(v is None for v in row.values()):raise ValueError('Malformed CSV record')
                key=row['Complaint ID'].strip()
                if not key or key in ids:raise ValueError('Missing/duplicate complaint ID: '+key)
                if row['Product']!='Credit card':raise ValueError('Unexpected product')
                received=datetime.fromisoformat(row['Date received'].replace('Z','+00:00'))
                sent=datetime.fromisoformat(row['Date sent to company'].replace('Z','+00:00'))
                if received.year!=year or sent<received:raise ValueError('Date cohort/chronology mismatch')
                ids.add(key);row['Source Year']=str(year);records.append(row);count+=1
        print(f'{year}: {count:,} records')
    a.output.parent.mkdir(parents=True,exist_ok=True)
    with a.output.open('x',encoding='utf-8-sig',newline='') as f:
        w=csv.DictWriter(f,fieldnames=headers+['Source Year']);w.writeheader();w.writerows(records)
    print(f'Combined {len(records):,} records with unique IDs: {a.output}')

if __name__=='__main__':main()
