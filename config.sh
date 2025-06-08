#!/bin/bash

PTR="Canon_PIXMA_TS3380"

service cups start

echo "Configuring the printer $PTR."
lpadmin -p $PTR -v cups-pdf:/ -E -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd

echo "Setting the default printer to $PTR."
lpadmin -d $PTR

# 找出cups-pdf.conf文件并修改输出目录
CUPS_PDF_CONF=$(find /etc -name cups-pdf.conf)
if [ -n "$CUPS_PDF_CONF" ]; then
  # 备份原始配置
  cp $CUPS_PDF_CONF ${CUPS_PDF_CONF}.bak
  # 修改输出目录
  sed -i 's|^Out .*|Out /root/PDF|' $CUPS_PDF_CONF
  # 禁用任何额外处理，但保持PDF高质量
  sed -i 's/^PostProcessing.*/PostProcessing ""/' $CUPS_PDF_CONF
  # 保持PDF高质量 (值为2或3保持高质量)
  sed -i 's/^PDFSettings.*/PDFSettings 3/' $CUPS_PDF_CONF
fi

service cups stop
