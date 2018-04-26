---
title     : "Typed: Typed Lambda term representation"
layout    : page
permalink : /Typed
---


## Imports

\begin{code}
module Typed where
\end{code}

\begin{code}
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; refl; sym; trans; cong; cong₂; _≢_)
open import Data.Empty using (⊥; ⊥-elim)
open import Data.List using (List; []; _∷_; [_]; _++_; map; foldr; filter)
open import Data.List.Any using (Any; here; there)
open import Data.Nat using (ℕ; zero; suc; _+_; _∸_; _≤_; _⊔_; _≟_)
open import Data.Nat.Properties using (≤-refl; ≤-trans; m≤m⊔n; n≤m⊔n; 1+n≰n)
open import Data.Product using (_×_; proj₁; proj₂; ∃; ∃-syntax)
              renaming (_,_ to ⟨_,_⟩)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Unit using (⊤; tt)
open import Function using (_∘_)
open import Function.Equality using (≡-setoid)
open import Function.Equivalence using (_⇔_; equivalence)
open import Relation.Nullary using (¬_; Dec; yes; no)
open import Relation.Nullary.Negation using (contraposition; ¬?)
open import Relation.Nullary.Product using (_×-dec_)
open import Collections using (_↔_)
\end{code}


## Syntax

\begin{code}
infixr 5 _⟹_
infixl 5 _,_⦂_
infix  4 _∋_⦂_
infix  4 _⊢_⦂_
infix  5 `λ_⇒_
infix  5 `λ_
infixl 6 `if0_then_else_
infix  7 `suc_ `pred_ `Y_
infixl 8 _·_
infix  9 `_

Id : Set
Id = ℕ

data Type : Set where
  `ℕ  : Type
  _⟹_ : Type → Type → Type

data Env : Set where
  ε     : Env
  _,_⦂_ : Env → Id → Type → Env

data Term : Set where
  `_              : Id → Term
  `λ_⇒_           : Id → Term → Term
  _·_             : Term → Term → Term
  `zero           : Term    
  `suc_           : Term → Term
  `pred_          : Term → Term
  `if0_then_else_ : Term → Term → Term → Term
  `Y_             : Term → Term

data _∋_⦂_ : Env → Id → Type → Set where

  Z : ∀ {Γ A x}
      -----------------
    → Γ , x ⦂ A ∋ x ⦂ A

  S : ∀ {Γ A B x w}
    → w ≢ x
    → Γ ∋ w ⦂ B
      -----------------
    → Γ , x ⦂ A ∋ w ⦂ B

data _⊢_⦂_ : Env → Term → Type → Set where

  `_ : ∀ {Γ A x}
    → Γ ∋ x ⦂ A
      ---------------------
    → Γ ⊢ ` x ⦂ A

  `λ_ : ∀ {Γ x N A B}
    → Γ , x ⦂ A ⊢ N ⦂ B
      ------------------------
    → Γ ⊢ (`λ x ⇒ N) ⦂ A ⟹ B

  _·_ : ∀ {Γ L M A B}
    → Γ ⊢ L ⦂ A ⟹ B
    → Γ ⊢ M ⦂ A
      --------------
    → Γ ⊢ L · M ⦂ B

  `zero : ∀ {Γ}
      --------------
    → Γ ⊢ `zero ⦂ `ℕ

  `suc_ : ∀ {Γ M}
    → Γ ⊢ M ⦂ `ℕ
      ---------------
    → Γ ⊢ `suc M ⦂ `ℕ

  `pred_ : ∀ {Γ M}
    → Γ ⊢ M ⦂ `ℕ
      ----------------
    → Γ ⊢ `pred M ⦂ `ℕ

  `if0 : ∀ {Γ L M N A}
    → Γ ⊢ L ⦂ `ℕ
    → Γ ⊢ M ⦂ A
    → Γ ⊢ N ⦂ A
      ----------------------------
    → Γ ⊢ `if0 L then M else N ⦂ A

  `Y_ : ∀ {Γ M A}
    → Γ ⊢ M ⦂ A ⟹ A
      ---------------
    → Γ ⊢ `Y M ⦂ A
\end{code}

## Test examples

\begin{code}
m n s z : Id
m = 0
n = 1
s = 2
z = 3

s≢z : s ≢ z
s≢z ()

n≢z : n ≢ z
n≢z ()

n≢s : n ≢ s
n≢s ()

m≢z : m ≢ z
m≢z ()

m≢s : m ≢ s
m≢s ()

m≢n : m ≢ n
m≢n ()

Ch : Type
Ch = (`ℕ ⟹ `ℕ) ⟹ `ℕ ⟹ `ℕ

twoCh : Term
twoCh = `λ s ⇒ `λ z ⇒ (` s · (` s · ` z))

⊢twoCh : ε ⊢ twoCh ⦂ Ch
⊢twoCh = `λ `λ ` ⊢s · (` ⊢s · ` ⊢z)
  where
  ⊢s = S s≢z Z
  ⊢z = Z

fourCh : Term
fourCh = `λ s ⇒ `λ z ⇒ ` s · (` s · (` s · (` s · ` z)))

⊢fourCh : ε ⊢ fourCh ⦂ Ch
⊢fourCh = `λ `λ ` ⊢s · (` ⊢s · (` ⊢s · (` ⊢s · ` ⊢z)))
  where
  ⊢s = S s≢z Z
  ⊢z = Z

plusCh : Term
plusCh = `λ m ⇒ `λ n ⇒ `λ s ⇒ `λ z ⇒ ` m · ` s · (` n · ` s · ` z)

⊢plusCh : ε ⊢ plusCh ⦂ Ch ⟹ Ch ⟹ Ch
⊢plusCh = `λ `λ `λ `λ  ` ⊢m ·  ` ⊢s · (` ⊢n · ` ⊢s · ` ⊢z)
  where
  ⊢z = Z
  ⊢s = S s≢z Z
  ⊢n = S n≢z (S n≢s Z)
  ⊢m = S m≢z (S m≢s (S m≢n Z))

fourCh′ : Term
fourCh′ = plusCh · twoCh · twoCh

⊢fourCh′ : ε ⊢ fourCh′ ⦂ Ch
⊢fourCh′ = ⊢plusCh · ⊢twoCh · ⊢twoCh

fromCh : Term
fromCh = `λ m ⇒ ` m · (`λ s ⇒ `suc ` s) · `zero

⊢fromCh : ε ⊢ fromCh ⦂ Ch ⟹ `ℕ
⊢fromCh = `λ ` ⊢m · (`λ `suc ` ⊢s) · `zero
  where
  ⊢m = Z
  ⊢s = Z
\end{code}


# Denotational semantics

\begin{code}
⟦_⟧ᵀ : Type → Set
⟦ `ℕ ⟧ᵀ      =  ℕ
⟦ A ⟹ B ⟧ᵀ  =  ⟦ A ⟧ᵀ → ⟦ B ⟧ᵀ

⟦_⟧ᴱ : Env → Set
⟦ ε ⟧ᴱ          =  ⊤
⟦ Γ , x ⦂ A ⟧ᴱ  =  ⟦ Γ ⟧ᴱ × ⟦ A ⟧ᵀ

⟦_⟧ⱽ : ∀ {Γ x A} → Γ ∋ x ⦂ A → ⟦ Γ ⟧ᴱ → ⟦ A ⟧ᵀ
⟦ Z ⟧ⱽ     ⟨ ρ , v ⟩ = v
⟦ S _ x ⟧ⱽ ⟨ ρ , v ⟩ = ⟦ x ⟧ⱽ ρ

⟦_⟧ : ∀ {Γ M A} → Γ ⊢ M ⦂ A → ⟦ Γ ⟧ᴱ → ⟦ A ⟧ᵀ
⟦ ` x ⟧      ρ       =  ⟦ x ⟧ⱽ ρ
⟦ `λ ⊢N ⟧    ρ       =  λ{ v → ⟦ ⊢N ⟧ ⟨ ρ , v ⟩ }
⟦ ⊢L · ⊢M ⟧  ρ       =  (⟦ ⊢L ⟧ ρ) (⟦ ⊢M ⟧ ρ)
⟦ `zero ⟧    ρ       =  zero
⟦ `suc ⊢M ⟧  ρ       =  suc (⟦ ⊢M ⟧ ρ)
⟦ `pred ⊢M ⟧ ρ       =  pred (⟦ ⊢M ⟧ ρ)
  where
  pred : ℕ → ℕ
  pred zero     =  zero
  pred (suc n)  =  n
⟦ `if0 ⊢L ⊢M ⊢N ⟧ ρ  =  if0 ⟦ ⊢L ⟧ ρ then ⟦ ⊢M ⟧ ρ else ⟦ ⊢N ⟧ ρ
  where
  if0_then_else_ : ∀ {A} → ℕ → A → A → A
  if0 zero  then m else n  =  m
  if0 suc _ then m else n  =  n
⟦ `Y ⊢M ⟧    ρ       =  {!!}

_ : ⟦ ⊢fourCh′ ⟧ tt ≡ ⟦ ⊢fourCh ⟧ tt
_ = refl

_ : ⟦ ⊢fourCh ⟧ tt suc zero ≡ 4
_ = refl
\end{code}


## Erasure

\begin{code}
lookup : ∀ {Γ x A} → Γ ∋ x ⦂ A → Id
lookup {Γ , x ⦂ A} Z        =  x
lookup {Γ , x ⦂ A} (S _ k)  =  lookup {Γ} k

erase : ∀ {Γ M A} → Γ ⊢ M ⦂ A → Term
erase (` k)             =  ` lookup k
erase (`λ_ {x = x} ⊢N)  =  `λ x ⇒ erase ⊢N
erase (⊢L · ⊢M)         =  erase ⊢L · erase ⊢M
erase (`zero)           =  `zero
erase (`suc ⊢M)         =  `suc (erase ⊢M)
erase (`pred ⊢M)        =  `pred (erase ⊢M)
erase (`if0 ⊢L ⊢M ⊢N)   =  `if0 (erase ⊢L) then (erase ⊢M) else (erase ⊢N)
erase (`Y ⊢M)           =  `Y (erase ⊢M)
\end{code}

### Properties of erasure

\begin{code}
cong₃ : ∀ {A B C D : Set} (f : A → B → C → D) {s t u v x y} → 
                               s ≡ t → u ≡ v → x ≡ y → f s u x ≡ f t v y
cong₃ f refl refl refl = refl

lookup-lemma : ∀ {Γ x A} → (⊢x : Γ ∋ x ⦂ A) → lookup ⊢x ≡ x
lookup-lemma Z        =  refl
lookup-lemma (S _ k)  =  lookup-lemma k

erase-lemma : ∀ {Γ M A} → (⊢M : Γ ⊢ M ⦂ A) → erase ⊢M ≡ M
erase-lemma (` ⊢x)            =  cong `_ (lookup-lemma ⊢x)
erase-lemma (`λ_ {x = x} ⊢N)  =  cong (`λ x ⇒_) (erase-lemma ⊢N)
erase-lemma (⊢L · ⊢M)         =  cong₂ _·_ (erase-lemma ⊢L) (erase-lemma ⊢M)
erase-lemma (`zero)           =  refl
erase-lemma (`suc ⊢M)         =  cong `suc_ (erase-lemma ⊢M)
erase-lemma (`pred ⊢M)        =  cong `pred_ (erase-lemma ⊢M)
erase-lemma (`if0 ⊢L ⊢M ⊢N)   =  cong₃ `if0_then_else_
                                   (erase-lemma ⊢L) (erase-lemma ⊢M) (erase-lemma ⊢N)
erase-lemma (`Y ⊢M)           =  cong `Y_ (erase-lemma ⊢M)
\end{code}


## Substitution

### Lists as sets

\begin{code}
open Collections.CollectionDec (Id) (_≟_)
\end{code}

### Free variables

\begin{code}
free : Term → List Id
free (` x)                   =  [ x ]
free (`λ x ⇒ N)              =  free N \\ x
free (L · M)                 =  free L ++ free M
free (`zero)                 =  []
free (`suc M)                =  free M
free (`pred M)               =  free M
free (`if0 L then M else N)  =  free L ++ free M ++ free N
free (`Y M)                  =  free M
\end{code}

### Fresh identifier

\begin{code}
fresh : List Id → Id
fresh = foldr _⊔_ 0 ∘ map suc

⊔-lemma : ∀ {w xs} → w ∈ xs → suc w ≤ fresh xs
⊔-lemma {_} {_ ∷ xs} here        =  m≤m⊔n _ (fresh xs)
⊔-lemma {_} {_ ∷ xs} (there x∈)  =  ≤-trans (⊔-lemma x∈) (n≤m⊔n _ (fresh xs))

fresh-lemma : ∀ {x xs} → x ∈ xs → x ≢ fresh xs
fresh-lemma x∈ refl =  1+n≰n (⊔-lemma x∈)
\end{code}

### Identifier maps

\begin{code}
∅ : Id → Term
∅ x = ` x

infixl 5 _,_↦_

_,_↦_ : (Id → Term) → Id → Term → (Id → Term)
(ρ , x ↦ M) w with w ≟ x
...               | yes _   =  M
...               | no  _   =  ρ w
\end{code}

### Substitution

\begin{code}
subst : List Id → (Id → Term) → Term → Term
subst ys ρ (` x)       =  ρ x
subst ys ρ (`λ x ⇒ N)  =  `λ y ⇒ subst (y ∷ ys) (ρ , x ↦ ` y) N
  where
  y = fresh ys
subst ys ρ (L · M)     =  subst ys ρ L · subst ys ρ M
subst ys ρ (`zero)     =  `zero
subst ys ρ (`suc M)    =  `suc (subst ys ρ M)
subst ys ρ (`pred M)   =  `pred (subst ys ρ M)
subst ys ρ (`if0 L then M else N)
  =  `if0 (subst ys ρ L) then (subst ys ρ M) else (subst ys ρ N)
subst ys ρ (`Y M)      =  `Y (subst ys ρ M)  
                       
_[_:=_] : Term → Id → Term → Term
N [ x := M ]  =  subst (free M ++ (free N \\ x)) (∅ , x ↦ M) N
\end{code}


## Values

\begin{code}
data Value : Term → Set where

  Zero :
      ----------
      Value `zero

  Suc : ∀ {V}
    → Value V
      --------------
    → Value (`suc V)
      
  Fun : ∀ {x N}
      ---------------
    → Value (`λ x ⇒ N)
\end{code}

## Reduction

\begin{code}
infix 4 _⟶_

data _⟶_ : Term → Term → Set where

  ξ-·₁ : ∀ {L L′ M}
    → L ⟶ L′
      ----------------
    → L · M ⟶ L′ · M

  ξ-·₂ : ∀ {V M M′}
    → Value V
    → M ⟶ M′
      ----------------
    → V · M ⟶ V · M′

  β-⟹ : ∀ {x N V}
    → Value V
      ------------------------------
    → (`λ x ⇒ N) · V ⟶ N [ x := V ]

  ξ-suc : ∀ {M M′}
    → M ⟶ M′
      ------------------
    → `suc M ⟶ `suc M′

  ξ-pred : ∀ {M M′}
    → M ⟶ M′
      --------------------
    → `pred M ⟶ `pred M′

  β-pred-zero :
      ---------------------
      `pred `zero ⟶ `zero

  β-pred-suc : ∀ {V}
    → Value V
      --------------------
    → `pred (`suc V) ⟶ V

  ξ-if0 : ∀ {L L′ M N}
    → L ⟶ L′
      ----------------------------------------------
    → `if0 L then M else N ⟶ `if0 L′ then M else N

  β-if0-zero : ∀ {M N}
      ------------------------------
    → `if0 `zero then M else N ⟶ M
  
  β-if0-suc : ∀ {V M N}
    → Value V
      ---------------------------------
    → `if0 (`suc V) then M else N ⟶ N

  ξ-Y : ∀ {M M′}
    → M ⟶ M′
      --------------
    → `Y M ⟶ `Y M′

  β-Y : ∀ {V x N}
    → Value V
    → V ≡ `λ x ⇒ N
      ------------------------
    → `Y V ⟶ N [ x := `Y V ]
\end{code}

## Reflexive and transitive closure

\begin{code}
infix  2 _⟶*_
infix 1 begin_
infixr 2 _⟶⟨_⟩_
infix 3 _∎

data _⟶*_ : Term → Term → Set where

  _∎ : ∀ {M}
      -------------
    → M ⟶* M

  _⟶⟨_⟩_ : ∀ (L : Term) {M N}
    → L ⟶ M
    → M ⟶* N
      ---------
    → L ⟶* N

begin_ : ∀ {M N} → (M ⟶* N) → (M ⟶* N)
begin M⟶*N = M⟶*N
\end{code}

## Canonical forms

\begin{code}
data Canonical : Term → Type → Set where

  Zero : 
      ------------------
      Canonical `zero `ℕ

  Suc : ∀ {V}
    → ε ⊢ V ⦂ `ℕ
    → Value V
      ---------------------
    → Canonical (`suc V) `ℕ
 
  Fun : ∀ {x N A B}
    → ε , x ⦂ A ⊢ N ⦂ B
      ------------------------------
    → Canonical (`λ x ⇒ N) (A ⟹ B)
\end{code}

## Canonical forms lemma

Every typed value is canonical.

\begin{code}
canonical : ∀ {V A}
  → ε ⊢ V ⦂ A
  → Value V
    -------------
  → Canonical V A
canonical `zero     Zero      =  Zero
canonical (`suc ⊢V) (Suc VV)  =  Suc ⊢V VV
canonical (`λ ⊢N)   Fun       =  Fun ⊢N
\end{code}

Every canonical form is typed and a value.

\begin{code}
typed : ∀ {V A}
  → Canonical V A
    -------------
  → ε ⊢ V ⦂ A
typed Zero         =  `zero
typed (Suc ⊢V VV)  =  `suc ⊢V
typed (Fun ⊢N)     =  `λ ⊢N

value : ∀ {V A}
  → Canonical V A
    -------------
  → Value V
value Zero         =  Zero
value (Suc ⊢V VV)  =  Suc VV
value (Fun ⊢N)     =  Fun
\end{code}
    
## Progress

\begin{code}
data Progress (M : Term) : Set where
  step : ∀ {N}
    → M ⟶ N
      ----------
    → Progress M
  done :
      Value M
      ----------
    → Progress M

progress : ∀ {M A} → ε ⊢ M ⦂ A → Progress M
progress (` ())
progress (`λ ⊢N)                           =  done Fun
progress (⊢L · ⊢M) with progress ⊢L
...    | step L⟶L′                       =  step (ξ-·₁ L⟶L′)
...    | done VL with canonical ⊢L VL
...        | Fun _ with progress ⊢M
...            | step M⟶M′               =  step (ξ-·₂ Fun M⟶M′)
...            | done VM                   =  step (β-⟹ VM)
progress `zero                             =  done Zero
progress (`suc ⊢M) with progress ⊢M
...    | step M⟶M′                       =  step (ξ-suc M⟶M′)
...    | done VM                           =  done (Suc VM)
progress (`pred ⊢M) with progress ⊢M
...    | step M⟶M′                       =  step (ξ-pred M⟶M′)
...    | done VM with canonical ⊢M VM
...        | Zero                          =  step β-pred-zero
...        | Suc ⊢V VV                     =  step (β-pred-suc VV)
progress (`if0 ⊢L ⊢M ⊢N) with progress ⊢L
...    | step L⟶L′                       =  step (ξ-if0 L⟶L′)
...    | done VL with canonical ⊢L VL
...        | Zero                          =  step β-if0-zero
...        | Suc ⊢V VV                     =  step (β-if0-suc VV)
progress (`Y ⊢M) with progress ⊢M
...    | step M⟶M′                       =  step (ξ-Y M⟶M′)
...    | done VM with canonical ⊢M VM
...        | Fun _                         =  step (β-Y VM refl)
\end{code}


## Preservation

### Domain of an environment

\begin{code}
dom : Env → List Id
dom ε            =  []
dom (Γ , x ⦂ A)  =  x ∷ dom Γ

dom-lemma : ∀ {Γ y B} → Γ ∋ y ⦂ B → y ∈ dom Γ
dom-lemma Z           =  here
dom-lemma (S x≢y ⊢y)  =  there (dom-lemma ⊢y)

free-lemma : ∀ {Γ M A} → Γ ⊢ M ⦂ A → free M ⊆ dom Γ
free-lemma (` ⊢x) w∈ with w∈
...                     | here          =  dom-lemma ⊢x
...                     | there ()   
free-lemma {Γ} (`λ_ {N = N} ⊢N)         =  ∷-to-\\ (free-lemma ⊢N)
free-lemma (⊢L · ⊢M) w∈ with ++-to-⊎ w∈
...                        | inj₁ ∈L    = free-lemma ⊢L ∈L
...                        | inj₂ ∈M    = free-lemma ⊢M ∈M
free-lemma `zero ()
free-lemma (`suc ⊢M) w∈                 = free-lemma ⊢M w∈
free-lemma (`pred ⊢M) w∈                = free-lemma ⊢M w∈
free-lemma (`if0 ⊢L ⊢M ⊢N) w∈
        with ++-to-⊎ w∈
...         | inj₁ ∈L                   = free-lemma ⊢L ∈L
...         | inj₂ ∈MN with ++-to-⊎ ∈MN
...                       | inj₁ ∈M     = free-lemma ⊢M ∈M
...                       | inj₂ ∈N     = free-lemma ⊢N ∈N
free-lemma (`Y ⊢M) w∈                   = free-lemma ⊢M w∈       
\end{code}

### Renaming

\begin{code}
⊢rename : ∀ {Γ Δ xs}
  → (∀ {x A} → x ∈ xs      →  Γ ∋ x ⦂ A  →  Δ ∋ x ⦂ A)
    --------------------------------------------------
  → (∀ {M A} → free M ⊆ xs →  Γ ⊢ M ⦂ A  →  Δ ⊢ M ⦂ A)
⊢rename ⊢σ ⊆xs (` ⊢x)      =  ` ⊢σ ∈xs ⊢x
  where
  ∈xs = ⊆xs here
⊢rename {Γ} {Δ} {xs} ⊢σ ⊆xs (`λ_ {x = x} {N = N} {A = A} ⊢N)
                           =  `λ (⊢rename {Γ′} {Δ′} {xs′} ⊢σ′ ⊆xs′ ⊢N)
  where
  Γ′   =  Γ , x ⦂ A
  Δ′   =  Δ , x ⦂ A
  xs′  =  x ∷ xs

  ⊢σ′ : ∀ {w B} → w ∈ xs′ → Γ′ ∋ w ⦂ B → Δ′ ∋ w ⦂ B
  ⊢σ′ w∈′ Z          =  Z
  ⊢σ′ w∈′ (S w≢ ⊢w)  =  S w≢ (⊢σ ∈w ⊢w)
    where
    ∈w  =  there⁻¹ w∈′ w≢

  ⊆xs′ : free N ⊆ xs′
  ⊆xs′ = \\-to-∷ ⊆xs
⊢rename ⊢σ ⊆xs (⊢L · ⊢M)   =  ⊢rename ⊢σ L⊆ ⊢L · ⊢rename ⊢σ M⊆ ⊢M
  where
  L⊆ = trans-⊆ ⊆-++₁ ⊆xs
  M⊆ = trans-⊆ ⊆-++₂ ⊆xs
⊢rename ⊢σ ⊆xs (`zero)     =  `zero
⊢rename ⊢σ ⊆xs (`suc ⊢M)   =  `suc (⊢rename ⊢σ ⊆xs ⊢M)
⊢rename ⊢σ ⊆xs (`pred ⊢M)  =  `pred (⊢rename ⊢σ ⊆xs ⊢M)
⊢rename ⊢σ ⊆xs (`if0 {L = L} ⊢L ⊢M ⊢N)
  = `if0 (⊢rename ⊢σ L⊆ ⊢L) (⊢rename ⊢σ M⊆ ⊢M) (⊢rename ⊢σ N⊆ ⊢N)
    where
    L⊆ = trans-⊆ ⊆-++₁ ⊆xs
    M⊆ = trans-⊆ ⊆-++₁ (trans-⊆ (⊆-++₂ {free L}) ⊆xs)
    N⊆ = trans-⊆ ⊆-++₂ (trans-⊆ (⊆-++₂ {free L}) ⊆xs)
⊢rename ⊢σ ⊆xs (`Y ⊢M)     =  `Y (⊢rename ⊢σ ⊆xs ⊢M)
    
\end{code}


### Substitution preserves types

\begin{code}
⊢subst : ∀ {Γ Δ xs ys ρ}
  → (∀ {x}   → x ∈ xs      →  free (ρ x) ⊆ ys)
  → (∀ {x A} → x ∈ xs      →  Γ ∋ x ⦂ A  →  Δ ⊢ ρ x ⦂ A)
    -------------------------------------------------------------
  → (∀ {M A} → free M ⊆ xs →  Γ ⊢ M ⦂ A  →  Δ ⊢ subst ys ρ M ⦂ A)
⊢subst Σ ⊢ρ ⊆xs (` ⊢x)
    =  ⊢ρ (⊆xs here) ⊢x
⊢subst {Γ} {Δ} {xs} {ys} {ρ} Σ ⊢ρ ⊆xs (`λ_ {x = x} {N = N} {A = A} ⊢N)
    = `λ_ {x = y} {A = A} (⊢subst {Γ′} {Δ′} {xs′} {ys′} {ρ′} Σ′ ⊢ρ′ ⊆xs′ ⊢N)
  where
  y   =  fresh ys
  Γ′  =  Γ , x ⦂ A
  Δ′  =  Δ , y ⦂ A
  xs′ =  x ∷ xs
  ys′ =  y ∷ ys
  ρ′  =  ρ , x ↦ ` y

  Σ′ : ∀ {w} → w ∈ xs′ →  free (ρ′ w) ⊆ ys′
  Σ′ {w} w∈′ with w ≟ x
  ...            | yes refl    =  ⊆-++₁
  ...            | no  w≢      =  ⊆-++₂ ∘ Σ (there⁻¹ w∈′ w≢)
  
  ⊆xs′ :  free N ⊆ xs′
  ⊆xs′ =  \\-to-∷ ⊆xs

  ⊢σ : ∀ {w C} → w ∈ ys → Δ ∋ w ⦂ C → Δ′ ∋ w ⦂ C
  ⊢σ w∈ ⊢w  =  S (fresh-lemma w∈) ⊢w

  ⊢ρ′ : ∀ {w C} → w ∈ xs′ → Γ′ ∋ w ⦂ C → Δ′ ⊢ ρ′ w ⦂ C
  ⊢ρ′ {w} _ Z with w ≟ x
  ...         | yes _             =  ` Z
  ...         | no  w≢            =  ⊥-elim (w≢ refl)
  ⊢ρ′ {w} w∈′ (S w≢ ⊢w) with w ≟ x
  ...         | yes refl          =  ⊥-elim (w≢ refl)
  ...         | no  _             =  ⊢rename {Δ} {Δ′} {ys} ⊢σ (Σ w∈) (⊢ρ w∈ ⊢w)
              where
              w∈  =  there⁻¹ w∈′ w≢

⊢subst Σ ⊢ρ ⊆xs (⊢L · ⊢M)
    =  ⊢subst Σ ⊢ρ L⊆ ⊢L · ⊢subst Σ ⊢ρ M⊆ ⊢M
  where
  L⊆ = trans-⊆ ⊆-++₁ ⊆xs
  M⊆ = trans-⊆ ⊆-++₂ ⊆xs
⊢subst Σ ⊢ρ ⊆xs `zero            =  `zero
⊢subst Σ ⊢ρ ⊆xs (`suc ⊢M)        =  `suc (⊢subst Σ ⊢ρ ⊆xs ⊢M)
⊢subst Σ ⊢ρ ⊆xs (`pred ⊢M)       =  `pred (⊢subst Σ ⊢ρ ⊆xs ⊢M)
⊢subst Σ ⊢ρ ⊆xs (`if0 {L = L} ⊢L ⊢M ⊢N)
    =  `if0 (⊢subst Σ ⊢ρ L⊆ ⊢L) (⊢subst Σ ⊢ρ M⊆ ⊢M) (⊢subst Σ ⊢ρ N⊆ ⊢N)
    where
    L⊆ = trans-⊆ ⊆-++₁ ⊆xs
    M⊆ = trans-⊆ ⊆-++₁ (trans-⊆ (⊆-++₂ {free L}) ⊆xs)
    N⊆ = trans-⊆ ⊆-++₂ (trans-⊆ (⊆-++₂ {free L}) ⊆xs)
⊢subst Σ ⊢ρ ⊆xs (`Y ⊢M)          =  `Y (⊢subst Σ ⊢ρ ⊆xs ⊢M)    

⊢substitution : ∀ {Γ x A N B M} →
  Γ , x ⦂ A ⊢ N ⦂ B →
  Γ ⊢ M ⦂ A →
  --------------------
  Γ ⊢ N [ x := M ] ⦂ B
⊢substitution {Γ} {x} {A} {N} {B} {M} ⊢N ⊢M =
  ⊢subst {Γ′} {Γ} {xs} {ys} {ρ} Σ ⊢ρ {N} {B} ⊆xs ⊢N
  where
  Γ′     =  Γ , x ⦂ A
  xs     =  free N
  ys     =  free M ++ (free N \\ x)
  ρ      =  ∅ , x ↦ M

  Σ : ∀ {w} → w ∈ xs → free (ρ w) ⊆ ys
  Σ {w} w∈ y∈ with w ≟ x
  ...            | yes _                   =  ⊆-++₁ y∈
  ...            | no w≢ rewrite ∈-[_] y∈  =  ⊆-++₂ (∈-≢-to-\\ w∈ w≢)
  
  ⊢ρ : ∀ {w B} → w ∈ xs → Γ′ ∋ w ⦂ B → Γ ⊢ ρ w ⦂ B
  ⊢ρ {w} w∈ Z         with w ≟ x
  ...                    | yes _     =  ⊢M
  ...                    | no  w≢    =  ⊥-elim (w≢ refl)
  ⊢ρ {w} w∈ (S w≢ ⊢w) with w ≟ x
  ...                    | yes refl  =  ⊥-elim (w≢ refl)
  ...                    | no  _     =  ` ⊢w

  ⊆xs : free N ⊆ xs
  ⊆xs x∈ = x∈
\end{code}

### Preservation

\begin{code}
preservation : ∀ {Γ M N A}
  →  Γ ⊢ M ⦂ A
  →  M ⟶ N
     ---------
  →  Γ ⊢ N ⦂ A
preservation (` ⊢x) ()
preservation (`λ ⊢N) ()
preservation (⊢L · ⊢M)              (ξ-·₁ L⟶L′)   =  preservation ⊢L L⟶L′ · ⊢M
preservation (⊢V · ⊢M)              (ξ-·₂ _ M⟶M′) =  ⊢V · preservation ⊢M M⟶M′
preservation ((`λ ⊢N) · ⊢W)         (β-⟹ _)       =  ⊢substitution ⊢N ⊢W
preservation (`zero)                ()
preservation (`suc ⊢M)              (ξ-suc M⟶M′)  =  `suc (preservation ⊢M M⟶M′)
preservation (`pred ⊢M)             (ξ-pred M⟶M′) =  `pred (preservation ⊢M M⟶M′)
preservation (`pred `zero)          (β-pred-zero)   =  `zero
preservation (`pred (`suc ⊢M))      (β-pred-suc _)  =  ⊢M
preservation (`if0 ⊢L ⊢M ⊢N)        (ξ-if0 L⟶L′)  =  `if0 (preservation ⊢L L⟶L′) ⊢M ⊢N
preservation (`if0 `zero ⊢M ⊢N)     β-if0-zero      =  ⊢M
preservation (`if0 (`suc ⊢V) ⊢M ⊢N) (β-if0-suc _)   =  ⊢N
preservation (`Y ⊢M)                (ξ-Y M⟶M′)    =  `Y (preservation ⊢M M⟶M′)
preservation (`Y (`λ ⊢N))           (β-Y _ refl)    =  ⊢substitution ⊢N (`Y (`λ ⊢N))
\end{code}


