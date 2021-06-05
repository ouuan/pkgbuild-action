# PKGBUILD Action

Make the package in a minimal environment and generate `.SRCINFO`.

## Inputs

### `path`

The path to the `PKGBUILD`.

## Outputs

### `pkgfile`

The path to the built package.

## Get Started

```yaml
      - name: Build Package
        uses: ouuan/pkgbuild-action@master
        id: build-package
        with:
          path: pkgname
      - name: Upload Artifacts
        uses: actions/upload-artifact@v2
        with:
          name: pkgname-${{ github.run_id }}
          path: ${{ steps.build-package.outputs.pkgfile }}
```
