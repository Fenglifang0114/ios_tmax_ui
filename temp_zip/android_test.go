package main

import (
	"archive/zip"
	"fmt"
	"io"
	"strings"
	jsoniter "github.com/json-iterator/go"
	"crypto/md5"
	"encoding/hex"
    "os"
)

var json = jsoniter.ConfigCompatibleWithStandardLibrary

const MD5SEED = "*T-Scale*"

type ReqFirmwareInfo struct {
	BinKey            string `json:"binKey"`
	SrecKey           string `json:"srecKey"`
	ModelName         string `json:"modelName"`
	Version           string `json:"version"`
	BootloaderVersion string `json:"bootloaderVersion"`
	BootAddress       string `json:"bootAddress"`
	SrecContentBytes  string `json:"srecContentBytes"`
}

func bytesToMd5(data []byte) string {
	h := md5.New()
	h.Write(data)
	return hex.EncodeToString(h.Sum(nil))
}

func mergeByteSlices(slice1, slice2 []byte) []byte {
	result := make([]byte, len(slice1)+len(slice2))
	copy(result[:len(slice1)], slice1)
	copy(result[len(slice1):], slice2)
	return result
}

func unzipAndReadFiles(zipPath string) ([]byte, []byte) {
	r, err := zip.OpenReader(zipPath)
	if err != nil {
		fmt.Println("Error opening ZIP:", err)
		return nil, nil
	}
	defer r.Close()

	var binData, infoData []byte
	res1 := false
	res2 := false

	if len(r.File) != 3 {
		fmt.Printf("ZIP file count is not 3: %d\n", len(r.File))
		return nil, nil
	}

	for _, f := range r.File {
		rc, err := f.Open()
		if err != nil {
			fmt.Println("Error opening file:", err)
			return nil, nil
		}
		defer rc.Close()

		buf := make([]byte, f.UncompressedSize64)
		_, err = io.ReadFull(rc, buf)
		if err != nil && err != io.EOF {
			fmt.Println("Error reading file:", err)
			return nil, nil
		}

		if strings.Contains(f.Name, ".bin") {
			binData = buf
			res1 = true
		} else if strings.Contains(f.Name, ".json") {
			infoData = buf
			res2 = true
		}
	}
	if res1 && res2 {
		return binData, infoData
	}
	fmt.Printf("res1: %v, res2: %v\n", res1, res2)
	return nil, nil
}

func getZipInfo(fileName string) ([]byte, string, error) {
	readBinData, txtData := unzipAndReadFiles(fileName)
	if readBinData == nil || txtData == nil {
		return nil, "", fmt.Errorf("file error: unzipAndReadFiles failed")
	}

	var firmwareInfo ReqFirmwareInfo
	if err := json.Unmarshal(txtData, &firmwareInfo); err != nil {
		return nil, "", fmt.Errorf("file error: json err %v", err)
	}
	readMd5 := firmwareInfo.BinKey
	tempByte := mergeByteSlices(readBinData, []byte(MD5SEED))
	calMd5Str := bytesToMd5(tempByte)
	if strings.Trim(readMd5, " ") != calMd5Str {
		return nil, "", fmt.Errorf("file error: md5 mismatch. Expected %s got %s", readMd5, calMd5Str)
	}

	modelName := firmwareInfo.ModelName
	return readBinData, modelName, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Provide zip path")
		return
	}
	zipPath := os.Args[1]
	_, modelName, err := getZipInfo(zipPath)
	if err != nil {
		fmt.Println("FAILED:", err)
	} else {
		fmt.Println("SUCCESS, modelName:", modelName)
	}
}
